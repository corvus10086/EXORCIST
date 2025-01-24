# Here is the user-mode program part of EXORCIST

# 0. Basic Environment

```bash
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev
sudo apt install libprocps-dev
sudo apt install libgmp-dev libmpfr-dev
sudo apt install libboost-all-dev
sudo apt install software-properties-common
sudo apt install libseccomp-dev
sudo apt install openssl
```
In addition, the beaengine library also needs to be compiled, and the compiled static library is placed in the lib folder  

# 2. How to Compile?
```bash
mkdir build
cd build
cmake ..
make
```
# 3. How to run？
After running the executable program, type start to start the test, and type stop to stop the test.  
The detected attacks will be saved in the find_attack directory under the build folder.  
