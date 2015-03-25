## How to build the Vagrant boxes

First, download and install Packer from <http://www.packer.io/docs/installation.html>.

Binaries for creating VirtualBox, VMWare Fusion, and Amazon EC2 boxes are provided in bin/.

Binary               | Host Environment
-------------------- | ----------------
bin/build-virtualbox | VirtualBox
bin/build-vmware     | VMWare Fusion
bin/build-aws        | Amazon EC2

Each binary takes a required set of arguments:

Argument               | Purpose
---------------------- | -------
bosh_release_version   | the BOSH release manifest version for the specific BOSH release
warden_release_version | the BOSH release manifest version for the BOSH Warden CPI release

Example: `bin/build-vbox 100 6`

Each binary also takes an optional build number, to be included in the output filename, defaults to 0.

### Amazon EC2 Only

`build-aws` requires `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to be set

Additionally, `bin/build-aws` takes optional arguments for base_ami (e.g. ami-864d84ee) and region (e.g. us-east-1) which are to be passed after the required arguments.

The default AMI, ami-d2ff23ba (us-east-1) is a public Ubuntu Trusty amd64 ebs AMI, found at http://cloud-images.ubuntu.com/locator/ec2/.

Please see usage for each binary for more details by running any of the binaries without any arguments.
