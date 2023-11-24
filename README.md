# Instrument-Classifier

This machine-learning-based instrument classifier made with SuperCollider and FluCoMa can learn the timbre of instruments through MFCC (mel-frequency cepstral coefficients) analysis. This program comes with a friendly user interface that allows everyone to play with simple machine learning. 

How to use:
1. Run the SuperCollider code. The user interface will pop up. 
2. Boot the server and then click on "Initialize".
3. Put your audio files for training in the same directory as the code file.
4. For each training file, copy the filename and enter the instrument name in the corresponding boxes. Make sure to hit the enter key. 
5. Click on "Add Point". The MFCC result will be automatically added to the dataset every 0.2 seconds while the audio file is being played. The sampling frequency can be changed if you want to. 
6. After getting all training data, click on "Train NN". The loss will be printed in the post window. Every click trains the neural network for 10 epochs. You may need to click multiple times for better results. 
6. Put your audio file(s) for testing in the same directory. Copy the filename, hit the enter key, and click on "Prediction Test". 
7. The predicted instrument name will be printed in the post window. 
8. Save the timbre data (MFCC results) and/or the neural network if you want to. 
