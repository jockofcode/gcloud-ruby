# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Vision::Project, :annotate, :labels, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }

  it "detects label detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    annotation = vision.annotate filepath, labels: 1
    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    annotation = vision.mark filepath, labels: 1
    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    annotation = vision.detect filepath, labels: 1
    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "LABEL_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "LABEL_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       labels_response_json]
    end

    annotations = vision.annotate filepath, filepath, labels: 1
    annotations.count.must_equal 2
    annotations.first.label.wont_be :nil?
    annotations.last.label.wont_be :nil?
  end

  it "uses the default configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_labels
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    annotation = vision.annotate filepath, labels: true
    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_labels
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    annotation = vision.annotate filepath, labels: "9999"
    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "uses the updated configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 25
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end


    Gcloud::Vision.stub :default_max_labels, 25 do
      annotation = vision.annotate filepath, labels: "9999"
      annotation.wont_be :nil?
      annotation.label.wont_be :nil?
    end
  end

  def label_response_json
    {
      responses: [{
        labelAnnotations: [label_annotation_response]
      }]
    }.to_json
  end

  def labels_response_json
    {
      responses: [{
        labelAnnotations: [label_annotation_response]
      }, {
        labelAnnotations: [label_annotation_response]
      }]
    }.to_json
  end

end
