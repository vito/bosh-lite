#!/usr/bin/env bash

set -e -x

source $(dirname $0)/lib/box.sh

cd bosh-lite

box_version=$(box_version)

create_vagrant_cloud_version(){
  result=`curl https://vagrantcloud.com/api/v1/box/${VAGRANT_CLOUD_BOX_NAME}/versions \
          -X POST \
          -d version[version]="$box_version" \
          -d access_token="$VAGRANT_CLOUD_ACCESS_TOKEN"`
  version_id=`echo $result | jq --raw-output ".number"`

  if [ "$version_id" = "null" ]; then
    echo "Failed to create version"
    exit 1
  fi

  echo $version_id
}

publish_to_s3(){
  for provider in "virtualbox" "aws"; do
    publish_vagrant_box_to_s3 $provider
  done
}

publish_to_vagrant_cloud(){
  version_id=`create_vagrant_cloud_version`

  for provider in "virtualbox" "aws"; do
    upload_box_to_vagrant_cloud $provider $provider $version_id
  done

  curl https://vagrantcloud.com/api/v1/box/${VAGRANT_CLOUD_BOX_NAME}/version/${version_id}/release \
    -X PUT \
    -d access_token="$VAGRANT_CLOUD_ACCESS_TOKEN"
}

commit_vagrant_file_version() {
  sed -i'' -e "s/override.vm.box_version = '.\{4\}'/override.vm.box_version = '$box_version'/" Vagrantfile
  git diff | cat
  git add Vagrantfile
  git commit -m "Update box version to $box_version"
}

upload_box_to_vagrant_cloud() {
  provider=$1
  box_type=$2
  version_id=$3

  curl https://vagrantcloud.com/api/v1/box/${VAGRANT_CLOUD_BOX_NAME}/version/${version_id}/providers \
    -X POST \
    -d provider[name]="$provider" \
    -d provider[url]="http://d2u2rxhdayhid5.cloudfront.net/bosh-lite-$box_type-ubuntu-trusty-$box_version.box" \
    -d access_token="$VAGRANT_CLOUD_ACCESS_TOKEN"
}

publish_vagrant_box_to_s3() {
  box_type=$1

  box_name="bosh-lite-${box_type}-ubuntu-trusty-${box_version}.box"
  s3cmd \
    --access_key=$BOSH_AWS_ACCESS_KEY_ID \
    --secret_key=$BOSH_AWS_SECRET_ACCESS_KEY \
    mv s3://$PIPELINE_BUCKET/$box_name s3://$FINAL_BOXES_BUCKET/$box_name
}

main() {
  # Be extra safe about version we are publishing
  if [ -z "$box_version" ]; then
    echo "Box version needs to be set!"
    exit 1
  fi

  if [ -z "$VAGRANT_CLOUD_ACCESS_TOKEN" ]; then
    echo "VAGRANT_CLOUD_ACCESS_TOKEN needs to be set"
    exit 1
  fi

  if [ -z "$VAGRANT_CLOUD_BOX_NAME" ]; then
    echo "VAGRANT_CLOUD_BOX_NAME needs to be set"
    exit 1
  fi

  if [ -z "$PIPELINE_BUCKET" ]; then
    echo "PIPELINE_BUCKET needs to be set"
    exit 1
  fi

  if [ -z "$FINAL_BOXES_BUCKET" ]; then
    echo "FINAL_BOXES_BUCKET needs to be set"
    exit 1
  fi

  # publish_to_s3
  # publish_to_vagrant_cloud
  commit_vagrant_file_version
}

main
