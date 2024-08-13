#!/bin/bash -e

# Tracks new connections made by launching a background tshark process, and also gets netstat connection stats

# Start tshark in the background to track new connections
function launch_tshark {
  # check if existing tshark is running
  if [ -n "$(pgrep tshark)" ]; then
    echo "Existing tshark already running, killing it"
    killall tshark
  fi
  tshark -l -i eth0 -f "tcp port 443" -Y "tls.handshake.type eq 1" -o gui.column.format:"Time,%Aut,Info,%i" > /tmp/hellos.log 2> /tmp/wireshark.log &
}

function cleanup {
  echo -e "\nEnd of run stats\n| active_time: $active_time | Total Conns: $total_connections | Peak Established: $peak_established | Peak Waiting: $peak_wait |"
  # echo "Cleaning up"
  kill -SIGTERM `pidof tshark dumpcap`
}

# main()
# catch control-C and cleanup
trap cleanup SIGINT SIGTERM
launch_tshark

total_connections=0
peak_established=0
peak_wait=0
active_time=0

while true; do
  # Get the current time in milliseconds
  timestamp_ms=$(date +%s%3N)

  # netstatout=$(netstat -an)
  # Get the number of connections from netstat
  established_count=$(netstat -an | grep -e ':443.*ESTABLISHED' | grep -v 'ffff' | wc -l)
  wait_count=$(netstat -an | grep -e ':443.*WAIT' | grep -v 'ffff' | wc -l)

  # Get the number of new connections from tshark
  # use the previous second, so we can capture a full second
  local_time=$(date -u -d "1 second ago" +%H:%M:%S)
  hellos_count=$(grep $local_time /tmp/hellos.log | wc -l)

  # Print the timestamp, number of connections, and number of new connections
  echo "$local_time new_connections: $hellos_count, established_connections: $established_count, waiting_to_close_connections: $wait_count"

  # Update the total number of connections
  total_connections=$((total_connections + hellos_count))
  peak_established=$((established_count > peak_established ? established_count : peak_established))
  peak_wait=$((wait_count > peak_wait ? wait_count : peak_wait))
  if [ $hellos_count -gt 0 ] || [ $total_connections -gt 0 ]; then
    active_time=$((active_time + 1))
  fi

  # get the elapsed time in ms
  elapsed_time_ms=$(($(date +%s%3N) - $timestamp_ms))
  # sleep for the remaining time in the second
  sleep_time_ms=$((1000 - $elapsed_time_ms))
  if [ $sleep_time_ms -gt 0 ]; then
    sleep 0.$sleep_time_ms
  fi
done
