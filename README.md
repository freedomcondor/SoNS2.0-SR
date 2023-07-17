## Guidelines
0. Clone this repo.
	```bash
	git clone https://github.com/freedomcondor/mns2.0.git
	```
1. This project requires a certain history version of argos3 (https://github.com/ilpincy/argos3) to be installed.
	The version to work with is:
	```bash
	commit c04be869311801976a83613552e111b2eef4dd45 (HEAD -> master, origin/master, origin/HEAD)
	Author: Michael Allwright <allsey87@gmail.com>
	Date:   Wed Dec 8 13:44:48 2021 +0100

	Fix the left-right wheel offset in the 3D dynamics model for the Pi-Puck (#196)
	```
	To clone ARGoS and switch to the right version :
	```bash
	git clone https://github.com/ilpincy/argos3
	cd argos3
	git checkout c04be869311801976a83613552e111b2eef4dd45
	```

2. Before compiling and installing argos, it is highly recommended to check and delete the old version of argos from your system. To do that, check /usr/local, which it is the default folder installing argos. To check:
	```bash
	cd /usr/local
	find . -name "*argos*"
	```

	All the files that contains the name argos will be listed. Check carefully to delete only argos files but not other system files. Usually, something like:
	```bash
	rm -rf */argos3
	```
	will do, but again, check carefully.

	After removing old versions argos, and cloning and checking out the desired history version of argos, you may want to apply some patch for argos3 from folder `argos3-patch`, depends on what do you need. For our mns experiments, two essential patches are needed, which are the first two described below:
* `new-camera-positions.patch` is essential, it makes drone cameras look farther than default, so that it works with pipuck-extension with larger tag. To apply the patch, go to argos3 folder and :
	```bash
	cd argos3
	git apply ../mns2.0/argos3-patch/new-camera-positions.patch
	```
	NOTE: If you follow exactly the bash command above, you will have argos3 folder and mns2.0 in parallel, otherwise you may need to adjust the path to locate mns2.0 folder.
* `unstable-drone.patch` is essential, it makes drone gyro and accelero meters more noisy so that the stablebility of the drone matches reality. 
	```bash
	git apply ../mns2.0/argos3-patch/unstable-drone.patch
	```
* `qtopengl-tweaks.patch` is used for fixing the argos qtopengl resolution to 1920x1080 and make drawings look nicer. This can be handy if you want to generate some fancy videos. WARNING: this patch may be outdated
* `drone_model.patch` is also used for nice videos. It updates drone model to make the appearing of the drone looks like the real drone in hardware.
* `babydrone.patch` is for hardware, to compile argos on a "virtual drone" on a PC. WARNING: also may be outdated.

3. To compile and install argos, follow the instructions of argos. Here is a guideline, you may need to change some details based on what you really need.
	```bash
	cd argos3
	mkdir build
	cd build
	cmake -DARGOS_BUILD_NATIVE=ON \
	      -DARGOS_DOCUMENTATION=OFF \
	      ../src
	make -j4
	sudo make install
	```

4. After installing argos3, you are clear to build mns2.0 repository. Go to mns2.0 repository and run the following commands.
	```bash
	cd mns2.0
	mkdir build
	cd build
	cmake ../src 
	make
	python3 experiments/exp_0_hw_01_formation_1_2d_10p/run.py
	```
	NOTE: If you are using macOS Big Sur with qt5, you may need to use `cmake -DARGOS_BREW_QT_CELLAR=$(brew --cellar qt@5) ../src`, for qt5 may not be found correctly by default under macOS.

	If everything is right, you should be able to see a group of drones and pipucks forming formations.

5. For hareware experiments, you need https://github.com/iridia-ulb/supervisor to manage all the robots. The tested version is
	```bash
	commit 68db21e732a95f5645fe0c51195bf24acc0f9f5e (HEAD -> master, origin/master, origin/HEAD)
	Author: Michael Allwright <allsey87@gmail.com>
	Date:   Fri Mar 4 15:41:23 2022 +0100
	    Update README.md
	```
	The patch, `mns2.0/argos3-patch/supervisor-router.patch` is also recommended, which would significantly reduce the amount of wifi messages.

## Folder Explanation
0. **argos3 and cmake :** `src/cmake` contains necessary cmake files to find argos3. `src/argos3` is a simbolic link to the parent folder, it is needed for loop function to compile. Usually you wouldn't need to touch these.

1. **ARGoS loop function and user function :** They are located in `src/extensions` and `src/qtopengl_extensions`. They are based on argos3-pipuck-ext (https://github.com/iridia-ulb/argos3-pipuck-ext). Thanks to Michael, they provide a general function for most of the testing cases. For example loop function creates pipuck-exts with larger tags and records the location of each robot. user function provides function to draw arrows. For details, please refer to argos3-pipuck-ext.

2. **SoNS core :**  The core source code of mns is located in `src/core`. Codes in these folders make the SoNS algorithm come true.

3. **experiments :** `src/experiments` is what the users play with. In this folder, each subfolder is a scenario case to test one or several features of SoNS, or an experiment in which a scenario got run for a load of times, and data collected, analyzed, and plotted. You can copy or create new subfolders to create your own scenarios and experiments.

	* **IMPORTANT NOTES:** The codes inside `src/experiments` are pre-executable. All the codes in `src/experiments` are generated executable by cmake in `build/experiments` folder.
	For example, if you check `src/experiments/exp_0_hw_01_formation_1_2d_10p/run.in.py` 
	you can see many like `@CMAKE_CURRENT_BINARY_DIR@` in it. After cmake and make, a `build/experiments/exp_0_hw_01_formation_1_2d_10p/run.py` will be generated, and these `@CMAKE_CURRENT_BINARY_DIR@` would be replaced by the absolute path of your folder. It is this file that you should run, and it doesn't matter which folder you are currently at, for everything is generated in absolute paths.
	This happens to most of the files in experiments, most of the files got a copy or an "configured" copy in build folder during make. So, if you want to change the code permanently, do it in `src`, and cmake again. Any change in build is only temporary and would be overwritten the next time you cmake.
	
## Scenario Explanation

The usual structure of each scenario is like this: the argos is wrapped by a python3 script. In the python script (usually `run.py`), it takes sons_template.argos as a template and generate a `sons.argos` file, filled with the content generated by python. For a explanation: `run.py` generates the initial locations of robots, writes them into sons.argos, and calls `argos3 -c sons.argos`

Therefore, to run an exp_* scenario, do:

```bash
cd mns2.0/build
python3 experiments/exp_0_hw_01_establish_formation_q_2d_10p/run.py -r 1
```
where `-r 1` at the end means randomseed 1. If there are no `-r 1` specified, a randomseed based on the current time will be automatically used.

Traverse all `exp_*` and you will see all the mns experiments. 

There is a README file in each folder to explain what does the scenario do.

For detailed information on how python generates argos files, there is a file in `src/scripts/createArgosScenario.py`. It is included by each `run.py` file in each `exp` scenario. It handles -r, -l, -z option, which is for randomseed, experiment length, and visualization, respectively. After getting randomseed and experiment length, python first generates robot initial positions (and other initial setups) and then generate a `.argos` file with the same randomseed, experiment length, and robot initial positions, and call `argos3` with this generated `.argos` file. 

## Other Notes

1. On the cluster, ARGOS_CMAKE_DIR is not found, cmake like the following will work
`cmake ../src/ -DARGOS_CMAKE_DIR=/home/wzhu/Programs/argos3/install/share/argos3/cmake`

2. For generating figures, a python tool is used for draw special markers in matplot
`pip3 install svgpathtools`
`pip3 install svgpath2mpl`