# How Far Can 100 Samples Go?

## Introduction
In this paper, we show that for an English-centric model, surprisingly large zero-shot improvements
can be achieved by simply fine-tuning with a very small amount of multi-parallel data. 
For example, on the EC30 dataset, we obtain up to +21.7 ChrF non-English overall improvements (870 directions) by using
only 100 multi-parallel samples while preserving English-centric translation quality.

<div style="text-align:center;">
    <img src="figures/Figure-1.png" width="300" height="300">
</div>

When investigating the size effect of fine-tuning data and its transfer capabilities, we found that :
1) Already a small, randomly sampled set of fine-tuning directions is sufficient to achieve comparable improvements.
2) The resulting non-English performance is close to the complete translation upper bound. 
3) Even in a minimal setting---fine-tuning with only one single sample---the well-known off-target issue is almost completely resolved, explaining parts--but not all---of the observed improvements in translation quality

## Code, Data, and Models
1. Code for the experiments: [Code](https://github.com/research-anonymous/MultiParallelFinetuning4MMT/tree/main/europarl_experiments)
2. Code for cooking data for Europarl-8 and EC30: [Code](xx)
3. Models: The English-centric, boosted and upper bound models (complete translation) will be released soon.


A more detailed codebase is on editing.