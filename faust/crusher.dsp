import("stdfaust.lib");
// TODO check the arrangement of components from the freeverb code
// Use the knobs

// Noise component with gain and cutoff
// TODO same for an oscillator
ct_freq = hslider("cutoffFrequency",250,50,500,0.01);
q_amount = hslider("q",5,1,10,0.1);
gain_vol = hslider("gain",0.2,0,0.5,0.01);
nice_noise(ctFreq,q,gain) = no.noise : fi.resonlp(ctFreq,q,gain);

// Drums with bitcrush
// TODO might need to change the values for an actual audio signal
// TODO mix dry and wet signals
// TODO consider mulaw
bit_slider = hslider("bit_depth",12,2,12,1);
//TODO Slider for the drums
bit_crushed_drums(bit_depth) = pm.djembe(60, 0.3, 0.4, 1), nice_noise(ct_freq, q_amount, gain_vol) :> ba.bitcrusher(bit_depth);

process = ba.pulsen(1, 10000) : bit_crushed_drums(bit_slider):dm.cubicnl_demo<: dm.freeverb_demo;
