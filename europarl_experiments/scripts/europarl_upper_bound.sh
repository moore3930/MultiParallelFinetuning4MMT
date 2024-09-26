#! /bin/bash

#SBATCH --partition=gpu
#SBATCH --gres=gpu:2
#SBATCH --ntasks=1
##SBATCH --nodelist=ilps-cn116
#SBATCH --exclude=ilps-cn111,ilps-cn101,ilps-cn102,ilps-cn103,ilps-cn104,ilps-cn105,ilps-cn106,ilps-cn107,ilps-cn108,ilps-cn109,ilps-cn110,ilps-cn112,ilps-cn113,ilps-cn114,ilps-cn115
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=7-10
##SBATCH --begin=now+1minute
#SBATCH --mail-type=BEGIN


#SBATCH -o /home/dwu/workplace/logs/multi-parallel/out.multi-2.o
#SBATCH -e /home/dwu/workplace/logs/multi-parallel/out.multi-2.e


export PATH=/home/diwu/anaconda3/bin:$PATH
source activate py37cuda11
export CUDA_HOME="/usr/local/cuda-11.0"
export PATH="${CUDA_HOME}/bin:${PATH}"
export LIBRARY_PATH="${CUDA_HOME}/lib64:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="/home/diwu/cudalibs:/usr/lib64/nvidia:${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

DATA_DIR=/ivi/ilps/personal/dwu/projects/multi-parallel/dataset/data_bin
CHECKPOINT_DIR=/ivi/ilps/personal/dwu/checkpoints/multi-parallel/multi

fairseq-train ${DATA_DIR} \
    --save-dir ${CHECKPOINT_DIR} \
    --langs en,da,de,es,fi,fr,it,nl \
    --lang-pairs en-da,da-en,en-de,de-en,en-es,es-en,en-fi,fi-en,en-fr,fr-en,en-it,it-en,en-nl,nl-en,da-de,de-da,da-es,es-da,da-fi,fi-da,da-fr,fr-da,da-it,it-da,da-nl,nl-da,de-es,es-de,de-fi,fi-de,de-fr,fr-de,de-it,it-de,de-nl,nl-de,es-fi,fi-es,es-fr,fr-es,es-it,it-es,es-nl,nl-es,fi-fr,fr-fi,fi-it,it-fi,fi-nl,nl-fi,fr-it,it-fr,fr-nl,nl-fr,it-nl,nl-it \
    --arch transformer_iwslt_de_en \
    --share-decoder-input-output-embed \
    --dropout 0.1 \
    --task translation_multi_simple_epoch \
    --sampling-method temperature \
    --sampling-temperature 2.0 \
    --encoder-langtok tgt \
    --criterion label_smoothed_cross_entropy \
    --label-smoothing 0.1 \
    --optimizer adam --adam-betas '(0.9, 0.98)' \
    --clip-norm 0.0 --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 --weight-decay 0.0 \
    --max-tokens 8192 --update-freq 8 --patience 10 --max-update 2000000 \
    --save-interval-updates 1000 --keep-interval-updates 1 \
    --no-epoch-checkpoints --seed 222 --log-format simple --log-interval 20 \
    --skip-invalid-size-inputs-valid-test \
    --fp16



# eval
PAIRS=('en-da' 'da-en' 'en-de' 'de-en' 'en-es' 'es-en' 'en-fi' 'fi-en' 'en-fr' 'fr-en' 'en-it' 'it-en' 'en-nl' 'nl-en' 'da-de' 'de-da' 'da-es' 'es-da' 'da-fi' 'fi-da' 'da-fr' 'fr-da' 'da-it' 'it-da' 'da-nl' 'nl-da' 'de-es' 'es-de' 'de-fi' 'fi-de' 'de-fr' 'fr-de' 'de-it' 'it-de' 'de-nl' 'nl-de' 'es-fi' 'fi-es' 'es-fr' 'fr-es' 'es-it' 'it-es' 'es-nl' 'nl-es' 'fi-fr' 'fr-fi' 'fi-it' 'it-fi' 'fi-nl' 'nl-fi' 'fr-it' 'it-fr' 'fr-nl' 'nl-fr' 'it-nl' 'nl-it')
for i in "${!PAIRS[@]}"; do
    PAIR=${PAIRS[i]}
    SRC=${PAIR%-*}
    TGT=${PAIR#*-}
    fairseq-generate ${DATA_DIR} \
        --task translation_multi_simple_epoch \
        --langs en,da,de,es,fi,fr,it,nl \
        --lang-pairs $PAIR \
        --source-lang $SRC \
        --target-lang $TGT \
        --sacrebleu \
        --remove-bpe 'sentencepiece' \
        --arch transformer_iwslt_de_en \
        --path ${CHECKPOINT_DIR}/checkpoint_best.pt \
        --sampling-method temperature \
        --skip-invalid-size-inputs-valid-test \
        --encoder-langtok tgt \
        --gen-subset test \
        --share-decoder-input-output-embed \
        --criterion label_smoothed_cross_entropy \
        --label-smoothing 0.1 \
        --max-tokens 10000 \
        --beam 5 \
        --seed 222 \
        --results-path ${CHECKPOINT_DIR}/xx/${SRC}-${TGT} \
        --fp16
done
