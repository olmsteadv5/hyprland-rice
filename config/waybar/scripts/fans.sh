#!/usr/bin/env bash
# explainer: shows the duty % fw-fanctrl is commanding, tooltip adds strategy, temp and RPM from the Framework EC
# decision: find the EC hwmon by name, hwmonN shifts between boots

status=$(fw-fanctrl --output-format JSON print all 2>/dev/null)

if [[ $(jq -r .status <<<"$status" 2>/dev/null) != success ]]; then
    printf '{"text":"󰈐 n/a","class":"missing","tooltip":"fw-fanctrl not responding"}\n'
    exit 0
fi

rpm=""
for h in /sys/class/hwmon/hwmon*; do
    [[ $(<"$h/name") == cros_ec ]] || continue
    for f in "$h"/fan*_input; do
        n=${f##*/fan}; n=${n%%_*}
        rpm+="\nFan $n: $(<"$f") RPM"
    done
    break
done

jq -c --arg rpm "$rpm" '
    (.speed | tonumber) as $s
    | {
        text: "󰈐 \($s)%",
        class: (if .active | not then "paused" elif $s >= 80 then "high" elif $s == 0 then "idle" else "spinning" end),
        tooltip: "Strategy: \(.strategy)\(if .active then "" else " (paused)" end)\nTemp: \(.effectiveTemperature)°C\(($rpm | gsub("\\\\n"; "\n")))"
      }' <<<"$status"
