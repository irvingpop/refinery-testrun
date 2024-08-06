#!/bin/bash
# This script is used to call an arbitrary number of load generator processes, picking a service name from the array below

# Default values for the arguments
num_proc=10
tps=3
runtime=10
ramptime=1

# Function to display usage
usage() {
  echo "Usage: $0 --services <number> --tps <number> --runtime <number> --ramptime <number>"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --services) num_proc="$2"; shift ;;
    --tps) tps="$2"; shift ;;
    --runtime) runtime="$2"; shift ;;
    --ramptime) ramptime="$2"; shift ;;
    *) usage ;;
  esac
  shift
done

if ! [[ $num_proc =~ ^[0-9]+$ ]] || ! [[ $tps =~ ^[0-9]+$ ]] || ! [[ $runtime =~ ^[0-9]+$ ]] || ! [[ $ramptime =~ ^[0-9]+$ ]]; then
  usage
fi

SERVICE_LIST=(
"tokyo" "newyork" "london" "paris" "berlin" "sydney" "moscow" "beijing" "dubai" "rome"
"toronto" "losangeles" "chicago" "houston" "miami" "sanfrancisco" "seattle" "boston" "atlanta" "dallas"
"vancouver" "montreal" "ottawa" "calgary" "edmonton" "winnipeg" "quebeccity" "victoria" "halifax" "stjohns"
"mexicocity" "guadalajara" "monterrey" "cancun" "tijuana" "puebla" "merida" "leon" "toluca" "chihuahua"
"buenosaires" "saopaulo" "riodejaneiro" "brasilia" "lima" "bogota" "santiago" "caracas" "quito" "lapaz"
"manila" "jakarta" "bangkok" "kualalumpur" "singapore" "hanoi" "hochiminhcity" "phnompenh" "vientiane" "yangon"
"seoul" "busan" "incheon" "daegu" "daejeon" "gwangju" "ulsan" "suwon" "changwon" "goyang"
"kyoto" "osaka" "nagoya" "sapporo" "fukuoka" "kobe" "hiroshima" "sendai" "kitakyushu" "chiba"
"melbourne" "brisbane" "perth" "adelaide" "canberra" "hobart" "darwin" "goldcoast" "newcastle" "wollongong"
"auckland" "wellington" "christchurch" "hamilton" "tauranga" "dunedin" "palmerstonnorth" "nelson" "rotorua" "napier"
"johannesburg" "capetown" "durban" "pretoria" "portelizabeth" "bloemfontein" "eastlondon" "kimberley" "polokwane" "nelspruit"
"cairo" "alexandria" "giza" "shubraelkheima" "portsaid" "suez" "luxor" "aswan" "mansoura" "tanta"
"casablanca" "rabat" "fes" "marrakech" "tangier" "agadir" "meknes" "oujda" "kenitra" "tetouan"
"algiers" "oran" "constantine" "annaba" "blida" "batna" "djelfa" "setif" "sidibelabbes" "biskra"
"tunis" "sfax" "sousse" "ettadhamen" "kairouan" "gabes" "bizerte" "ariana" "gafsa" "lagoulette"
"tripoli" "benghazi" "misrata" "bayda" "zawiya" "zliten" "khoms" "sabha" "sirte" "derna"
"riyadh" "jeddah" "mecca" "medina" "dammam" "khobar" "tabuk" "buraidah" "khamismushait" "hofuf"
"abudhabi" "sharjah" "alain" "ajman" "rasalkhaimah" "fujairah" "ummalquwain" "khorfakkan" "kalba"
"doha" "alrayyan" "ummsalal" "alkhor" "alwakrah" "alshahaniya" "aldaayen" "madinatashshamal" "lusail" "dukhan"
"manama" "riffa" "muharraq" "hamadtown" "isatown" "sitra" "budaiya" "jidhafs" "sanad" "tubli"
"kuwaitcity" "alahmadi" "hawalli" "salmiya" "sabahalsalem" "farwaniya" "jahra" "fahaheel" "mubarakalkabeer" "mahboula"
"muscat" "salalah" "sohar" "nizwa" "sur" "barka" "ibri" "rustaq" "buraimi" "khasab"
"amman" "zarqa" "irbid" "russeifa" "ajloun" "aqaba" "madaba" "mafraq" "jerash" "karak"
"beirut" "sidon" "tyre" "jounieh" "zahle" "baalbek" "byblos" "batroun" "aley"
"damascus" "aleppo" "homs" "latakia" "hama" "deirezzor" "raqqa" "idlib" "daraa" "tartus"
"baghdad" "basra" "mosul" "erbil" "kirkuk" "sulaymaniyah" "najaf" "karbala" "nasiriyah" "amarah"
"tehran" "mashhad" "isfahan" "karaj" "shiraz" "tabriz" "qom" "ahvaz" "kermanshah" "urmia"
"ankara" "istanbul" "izmir" "bursa" "adana" "gaziantep" "konya" "antalya" "kayseri" "mersin"
"athens" "thessaloniki" "patras" "heraklion" "larissa" "volos" "rhodes" "ioannina" "chania" "agrinio"
"milan" "naples" "turin" "palermo" "genoa" "bologna" "florence" "bari" "catania"
"madrid" "barcelona" "valencia" "seville" "zaragoza" "malaga" "murcia" "palma" "laspalmas" "bilbao"
"lisbon" "porto" "amadora" "braga" "coimbra" "funchal" "setubal" "aveiro" "evora" "faro"
"marseille" "lyon" "toulouse" "nice" "nantes" "strasbourg" "montpellier" "bordeaux" "lille"
"hamburg" "munich" "cologne" "frankfurt" "stuttgart" "dusseldorf" "dortmund" "essen" "leipzig"
"vienna" "graz" "linz" "salzburg" "innsbruck" "klagenfurt" "villach" "wels" "sanktpolten" "dornbirn"
"zurich" "geneva" "basel" "lausanne" "bern" "winterthur" "lucerne" "stgallen" "lugano" "biel"
"brussels" "antwerp" "ghent" "charleroi" "liege" "bruges" "namur" "leuven" "mons" "aalst"
"amsterdam" "rotterdam" "thehague" "utrecht" "eindhoven" "tilburg" "groningen" "almere" "breda" "nijmegen"
"copenhagen" "aarhus" "odense" "aalborg" "esbjerg" "randers" "kolding" "horsens" "vejle" "roskilde"
"stockholm" "gothenburg" "malmo" "uppsala" "vasteras" "orebro" "linkoping" "helsingborg" "jonkoping" "norrkoping"
"helsinki" "espoo" "tampere" "vantaa" "oulu" "turku" "jyväskylä" "lahti" "kuopio" "kouvola"
"oslo" "bergen" "trondheim" "stavanger" "drammen" "fredrikstad" "kristiansand" "sandnes" "tromso" "sarpsborg"
"reykjavik" "kopavogur" "hafnarfjordur" "akureyri" "reykjanesbaer" "gardabaer" "mosfellsbaer" "akranes" "selfoss" "seltjarnarnes"
"dublin" "cork" "limerick" "galway" "waterford" "drogheda" "swords" "dundalk" "bray" "navan"
"belfast" "derry" "lisburn" "newtownabbey" "bangor" "craigavon" "ballymena" "newry" "carrickfer"
"portland" "salem" "eugene" "gresham" "hillsboro" "beaverton" "bend" "medford" "springfield" "corvallis"
"albany" "tigard" "lakeoswego" "keizer" "grantspass" "oregoncity" "redmond" "tualatin" "westlinn" "woodburn"
"forestgrove" "wilsonville" "newberg" "rosecity" "sherwood" "canby" "centralpoint" "coosbay" "troutdale" "hermiston"
"ashland" "klamathfalls" "happyvalley" "milwaukie" "pendleton" "hoodriver" "thedalles" "astoria"
"ontario" "silverton" "sandy" "monmouth" "scappoose" "sutherlin" "warrenton" "cottagegrove" "bakercity"
"stayton" "northbend" "madras" "molalla" "sweethome" "sheridan" "jacksonville" "tillamook" "brookings"
"veneta" "philomath" "junctioncity" "myrtlepoint" "creswell" "lagrande" "prineville" "sthelens" "coburg"
"johnday" "goldbeach" "scio" "dayton" "estacada" "harrisburg" "willamina"
"canyonville" "dufur" "millcity" "yamhill" "riddle" "gaston" "lowell" "oakridge"
)

iter=0
for i in "${SERVICE_LIST[@]}" ; do
    if [ $iter -ge $num_proc ]; then
        break
    fi

    echo "Starting load generator for service $i"
    loadgen \
      --host=http://refinery:4317 \
      --insecure \
      --dataset="${i}" \
      --apikey="${HONEYCOMB_API_KEY}" \
      --tps=${tps} \
      --runtime="${runtime}s" \
      --ramptime="${ramptime}s" \
      --sender=otel \
      --protocol=grpc &

    iter=$((iter+1))
done

for p in $(jobs -p)
do
     wait "$p" || { echo "job $p failed" >&2; exit; }
done
