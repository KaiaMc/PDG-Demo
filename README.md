This project requires both Godot 4.5 and TouchDesigner to be installed and running simultaneously, along with a working webcam.

Download Instructions:

1. Download Godot 4.5 (tested on 4.5.1, though 4.5.2 should work. Not tested on newer/older versions) here: https://godotengine.org/download/archive/
2. Download Touchdesigner (latest) here: https://derivative.ca/download
3. Download the Touchdesginer project file, unzip, and open DynamicArtForCitizens.4.toe within the folder (folder too big for github, download here via google drive: https://drive.google.com/drive/folders/1YBtsx-qrEVPJbv1uTlcwuwiDbyhDf4MB?usp=sharing)
4. Download and open the Godot project file

From there, verify that your TouchDesigner file is open and running by checking the "play" button on the bottom panel. You should see your webcam being monitored on the "mediapipe" node.

Finally, in godot, navigate to the top right of the screen and select the "play" button. The project should automatically open in a new window.

TROUBLESHOOTING:
1. Right now to trigger fish spawns, the camera first has to detect no faces. Try covering your webcam for a second, the fish should spawn once you take your hand away.
2. If TouchDesigner is running but no signals are being detected, double check that the OSC server is running. Click on the "oscout1" and "oscout3" nodes in touch designer and, in the properties window, verify the network port. It should be 4646. If its not, ask me about it (something is weird)
