import("stdfaust.lib");

process = ba.pulsen(1, 10000) : bit_crushed_drums(bit_slider):cubicnl_demo<: freeverb_demo
with {
    // Noise component with gain and cutoff
    // TODO same for an oscillator

    //ct_freq = hslider("cutoffFrequency",250,50,500,0.01);
    //q_amount = hslider("q",5,1,10,0.1);
    //gain_vol = hslider("gain",0.2,0,0.5,0.01);
    nice_noise(ctFreq,q,gain) = no.noise : fi.resonlp(ctFreq,q,gain)
    with {
        n_col(x) = vgroup("NOISE nice_noice [tooltip: Noice tooltip]", x);
        ct_freq = n_col(hslider("[0] cutoffFrequency",250,50,500,0.01));
        q_amount = n_col(hslider("[1] q",5,1,10,0.1));
        gain_vol = n_col(hslider("[2] gain",0.2,0,0.5,0.01));
    };
    
    // Drums with bitcrush
    // TODO might need to change the values for an actual audio signal
    // TODO mix dry and wet signals
    // TODO consider mulaw
    bit_slider = hslider("bit_depth",12,2,12,1);
    //TODO Slider for the drums
    bit_crushed_drums(bit_depth) = pm.djembe(60, 0.3, 0.4, 1), nice_noise(ct_freq, q_amount, gain_vol) :> ba.bitcrusher(bit_depth);

    cubicnl_demo = ba.bypass1(bp, ef.cubicnl_nodc(drive:si.smoo,offset:si.smoo))
    with{
        cnl_group(x)  = vgroup("CUBIC NONLINEARITY cubicnl [tooltip: Reference:
            https://ccrma.stanford.edu/~jos/pasp/Cubic_Soft_Clipper.html]", x);
        bp = cnl_group(checkbox("[0] Bypass [tooltip: When this is checked, the
            nonlinearity has no effect]"));
        drive = cnl_group(hslider("[1] Drive [tooltip: Amount of distortion]",
            0, 0, 1, 0.01));
        offset = cnl_group(hslider("[2] Offset [tooltip: Brings in even harmonics]",
            0, 0, 1, 0.01));
    };

    freeverb_demo = _,_ <: (*(g)*fixedgain,*(g)*fixedgain :
        re.stereo_freeverb(combfeed, allpassfeed, damping, spatSpread)),
        *(1-g), *(1-g) :> _,_
    with{
        scaleroom   = 0.28;
        offsetroom  = 0.7;
        allpassfeed = 0.5;
        scaledamp   = 0.4;
        fixedgain   = 0.1;
        origSR = 44100;

        parameters(x) = hgroup("Freeverb",x);
        knobGroup(x) = parameters(vgroup("[0]",x));
        damping = knobGroup(vslider("[0] Damp [style: knob] [tooltip: Somehow control the
            density of the reverb.]",0.5, 0, 1, 0.025)*scaledamp*origSR/ma.SR);
        combfeed = knobGroup(vslider("[1] RoomSize [style: knob] [tooltip: The room size
            between 0 and 1 with 1 for the largest room.]", 0.5, 0, 1, 0.025)*scaleroom*
            origSR/ma.SR + offsetroom);
        spatSpread = knobGroup(vslider("[2] Stereo Spread [style: knob] [tooltip: Spatial
            spread between 0 and 1 with 1 for maximum spread.]",0.5,0,1,0.01)*46*ma.SR/origSR
            : int);
        g = parameters(vslider("[1] Wet [tooltip: The amount of reverb applied to the signal
            between 0 and 1 with 1 for the maximum amount of reverb.]", 0.3333, 0, 1, 0.025));
    };
};