this project reads in a jpeg file and creates an FM IQ file, that can be transmitted to a sdr device.
the IQ file is a wav file with sample rate of 48khz.
gnuradio can be used to tx iq file.
for rx any sdr software can be used.
to record iq for rx best to use raw mode and record the audio.
and be sure to have the signal tuned into the the passband of the sdr tuner.
when recording audio using the raw demod option, the file is not audio but rather iq file.
use the rx-iq-fm-image script to process the recorded iq file and display the image.
an iq file is posted in the github to test using gnu octave or matlab.
