import argparse
import os
import numpy as np
from collections import OrderedDict

def get_all_bleu(path, pairs=None):
    if pairs==None:
        dir_list = [os.path.basename(os.path.normpath(x[0])) for x in os.walk(path)][1:]
        print(dir_list)
    else:
        dir_list = pairs

    out_pairs = []
    out_scores = []
    out_scores_comet = []
    out_scores_sacrebleu = []
    out_scores_crf = []
    out_scores_ter = []
    for lang_pair in dir_list:
        try:
            with open(os.path.join(path, lang_pair, "generate-test.txt"), 'r') as fin:
                print("process {}...".format(lang_pair))
                last_line = fin.readlines()
                last_line = last_line[-1]
                cur = last_line.split('BLEU4 = ')[1].split(',')[0]
                cur = round(float(cur), 1)
                out_scores.append(str(cur))
                out_pairs.append(lang_pair)
            with open(os.path.join(path, lang_pair, "test_comet.txt"), 'r') as fin:
                last_line = fin.readlines()
                last_line = last_line[-1]
                cur = last_line.split('score: ')[-1]
                cur = round(float(cur) * 100, 1)
                out_scores_comet.append(str(cur))
            with open(os.path.join(path, lang_pair, "test_bleu.txt"), 'r') as fin:
                last_line = fin.readlines()
                last_line = last_line[-10]
                cur = last_line.split('\"score\": ')[1].split(',')[0]
                out_scores_sacrebleu.append(cur)
            with open(os.path.join(path, lang_pair, "test_chrfpp.txt"), 'r') as fin:
                last_line = fin.readlines()
                last_line = last_line[-10]
                cur = last_line.split('\"score\": ')[1].split(',')[0]
                out_scores_crf.append(cur)
            with open(os.path.join(path, lang_pair, "test_ter.txt"), 'r') as fin:
                last_line = fin.readlines()
                last_line = last_line[-10]
                cur = last_line.split('\"score\": ')[1].split(',')[0]
                out_scores_ter.append(cur)
        except:
            print("{} is not ready".format(lang_pair))

    return out_scores, out_scores_comet, out_scores_sacrebleu, out_scores_crf, out_scores_ter, out_pairs

    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-pairs', dest='pairs', default='')
    parser.add_argument('-result_dir', dest='result_dir', default='')
    parser.add_argument('-output', dest='output', default='')
    args = parser.parse_args()

    pairs = ""
    result_dir = args.result_dir

    with open(args.pairs) as fin:
        line = fin.readline()
        pairs = line.strip().split(",")

    out_scores, out_scores_comet, out_scores_sacrebleu, out_scores_crf, out_scores_ter, out_pairs = get_all_bleu(result_dir, pairs)
    
    with open(args.output, 'w') as fout:
        fout.write("{}\n{}\n{}\n{}\n{}\n{}\n".format(out_pairs, out_scores, out_scores_comet, out_scores_sacrebleu, out_scores_crf, out_scores_ter))
