#!/bin/bash
# shellcheck disable=SC2154
# shellcheck disable=SC2086
# shellcheck disable=SC2001

PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
engines=('google')
input=$1
trans=""
subtrans=""

lf=$'\\\x0A'

if [[ "$lang" == "${native_lang}2${foreign_lang}" ]]; then
  from="en"
  to="ja"
else
  from="en"
  to="ja"
fi

set_trans() {
  if [[ "${engines[*]}" =~ $engine ]]; then
    input=$(echo -n "$input" | sed 's/;/'"$lf"'/g')
    trans=$(trans "$from:$to" --engine "$engine" -b "$input" )
    subtrans=$(trans "$from:$to" "$input" | sed -e "1,2d" | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | grep -E "\(.*\)")

  elif [[ $engine == "deepl" ]]; then
    if [[ $deepl_api_url == "pro" ]]; then
      api_url=https://api.deepl.com/v2/translate
    else
      api_url=https://api-free.deepl.com/v2/translate
    fi
    local from_upper to_upper
    from_upper=$(echo "$from" | tr '[:lower:]' '[:upper:]')
    to_upper=$(echo "$to" | tr '[:lower:]' '[:upper:]')

    # Split input to multiple sentences.
    # Because DeepL API cannot translate overly long sentences.
    IFS=';'
    set -- $input
    trans=$(
      curl -s "$api_url" \
        -d auth_key="$deepl_api_key" \
        -d "text=$1" \
        -d "text=$2" \
        -d "text=$3" \
        -d "text=$4" \
        -d "text=$5" \
        -d "text=$6" \
        -d "text=$7" \
        -d "text=$8" \
        -d "text=$9" \
        -d "text=${10}" \
        -d "text=${11}" \
        -d "text=${12}" \
        -d "text=${13}" \
        -d "text=${14}" \
        -d "text=${15}" \
        -d "text=${16}" \
        -d "text=${17}" \
        -d "text=${18}" \
        -d "text=${19}" \
        -d "text=${20}" \
        -d "target_lang=$to_upper" \
        -d "source_lang=$from_upper"\
    )
    trans=$(echo "$trans" | jq -r .translations[].text)
    if [ -n "${21}" ]; then
      trans="$trans $lf ...too large volumes of text."
    fi
  else
    echo -n "'$engine' is unsupported engine"
    exit
  fi
}

run() {
  set_trans
  echo -n "$trans"
  echo "$subtrans"
}

filter() {
  set_trans
  cat <<EOB
{
	"variables": {
		"input": "$input",
		"output": "$trans",
		"lang": "$lang"
  	},
	"items": [
		{
			"uid": "eg1",
			"title": "$trans",
			"subtitle": "$subtrans",
			"arg": "$trans"
		}
	]
}
EOB
}

if [[ "$script_type" == "run" ]]; then
  run
else
  filter
fi
