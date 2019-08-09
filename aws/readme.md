# Speaker Recognition demo on AWS F1

All the steps must be executed on an AWS **f1.2xlarge** instance running **FPGA Developer AMI**.
Supported version is 1.6.0.

## Step 1: Before starting

* Prepare an AWS **f1.2xlarge** instance running **FPGA Developer AMI**

## Step 2: Install and update the FPGA drivers:

* Clone AWS F1 latest Git repository: `git clone https://github.com/aws/aws-fpga.git`
* Move to `aws-fpga` folder
* To install and update run: `source sdaccel_setup.sh`

## Step 2: Install and start Docker on AWS centOS

 [Docker user guide for AWS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker):
* Update system: `sudo yum update -y`
* Install Docker: `sudo yum install -y docker`
* Start Docker service: `sudo service docker start`
* `sudo groupadd docker`
* `sudo usermod -a -G docker centos`
* `sudo systemctl enable docker`
* Reboot the AWS instance

## Step3: Install Kubernetes on AWS FPGA Developer AMI

* `sudo yum install -y epel-release`
* `sudo yum install -y snapd`
* `sudo systemctl enable --now snapd.socket`
* `sudo ln -s /var/lib/snapd/snap /snap`
* power cycle the AWS instance
* `sudo snap install microk8s --classic`
*  Enable **privileged** mode on Kubernetes:
    * Add `--allow-privileged=true` to: `sudo vim /var/snap/microk8s/current/args/kube-apiserver`
    * Restart service: `sudo systemctl restart snap.microk8s.daemon-apiserver.service`
* Start Kubernetes `microk8s.start`
* Enable DNS and dashboard service `microk8s.enable dns dashboard`
* Docker login to the public registry: `docker login https://containerhub.xelera.io:4433` using username and password provided by Xelera.
* Configure Kubernetes: `microk8s.kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/centos/.docker/config.json --type=kubernetes.io/dockerconfigjson`. To verify the credential: `microk8s.kubectl get secret regcred --output=yaml`

## Step3: Clone the current repository on the AWS instance

`git clone https://github.com/xelera-technologies/SpeakerRecognition.git`

## Step 4: Run the demo

The Speaker Recognition demo supports a Docker deployment or a Kubernets one:

### Docker deployment
* Start the docker container `run_docker.sh`. This will start the Speaker Recognition http server (u-Xservice).
* Using a new terminal, to start a speaker's detection request send an input tensor (png format) as POST request to the API: `curl -XPOST -H "Content-Type: image/png" --data-binary @<path to png file> "http://127.0.0.1:8088`


### Kubernetes deployment

* Install Pod Security Policy: `microk8s.kubectl apply -f privileged.yaml`
* Install device plugin:
    * Install device plugin: `microk8s.kubectl apply -f aws-fpga-device-plugin.yaml`
    * Remove device plugin: `microk8s.kubectl delete -f aws-fpga-device-plugin.yaml`
    * Get node information: `microk8s.kubectl describe node`
    * Get pod list: `microk8s.kubectl get pods -n kube-system` (expected name for FPGAs devices: fpga-device-plugin-daemonset-xxxxxx)
    * Get pot debug log: `microk8s.kubectl logs fpga-device-plugin-daemonset-xxxxxx -n kube-system`
* Install application pod:
    * Create application pod: `microk8s.kubectl apply -f aws-pod.yaml`
    * Delete application pod: `microk8s.kubectl delete -f aws-pod.yaml`
    * Get application pod information: `microk8s.kubectl describe pod aws-dla-demo`
    * To start a speaker's detection request send an input tensor (png format) as POST request to the API: `curl -XPOST -H "Content-Type: image/png" --data-binary @<path to png file> "http://127.0.0.1:8088`.
