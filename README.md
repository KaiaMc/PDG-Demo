### This project requires both Godot and TouchDesigner to be installed and running simultaneously, along with a working webcam.

## DOWNLOAD INSTRUCTIONS:

1. Download Godot (tested on 4.5 and 4.7) here: https://godotengine.org/download/archive/
2. Download Touchdesigner (latest) here: https://derivative.ca/download
3. Download the Touchdesginer project file, unzip, and open PDG_TouchDesigner_Demo.toe within the folder (the folder is too big for github, download here via google drive: https://drive.google.com/drive/folders/1YBtsx-qrEVPJbv1uTlcwuwiDbyhDf4MB?usp=sharing)
4. Download and open the Godot project file

From there, verify that your TouchDesigner file is open and running by checking the "play" button on the bottom panel. You should see your webcam being monitored on the "mediapipe" node.

Finally, in godot, navigate to the top right of the screen and select the "play" button. The project should automatically open in a new window.

## HOW TO USE:
1. To trigger fish spawns, the camera first has to detect no faces. Cover your webcam (**NOT your face, cover the _WEBCAM_ to ensure no faces are detected**), the fish will appear once you take your hand away.
