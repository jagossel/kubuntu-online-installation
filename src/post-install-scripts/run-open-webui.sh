#!/bin/bash

if [ -z "$1" ]; then
	echo >&2 "The profile name is required."
	exit 1
fi

base_dir=$( dirname "$( readlink -f $0 )" )
models_list_path="$base_dir/models.csv"
if [ ! -f "$models_list_path" ]; then
	echo >&2 "Cannot find the path, $models_list_path."
	exit 1
fi

docker run -d \
	--publish 3000:8080 \
	--name open-webui \
	--volume ollama:/root/.ollama \
	--volume open-webui:/app/backend/data \
	--restart=unless-stopped \
	ghcr.io/open-webui/open-webui:ollama

grep -E ".*,.*,($1|\*)" $models_list_path | while IFS= read -r record; do
	model_name=$( echo "$record" | awk -F, '{ print $1 }' )
	tag_name=$( echo "$record" | awk -F, '{ print $2 }' )
	command_text="ollama pull $model_name:$tag_name"

	echo "Installing model, $model_name:$tag_name..."
	docker container exec open-webui $command_text
done
