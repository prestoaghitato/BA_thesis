# BA Thesis
Thesis Bachelor in Linguistics
## Basic Pattern Mining Stuff

### Apriori Algorithm

Commonly used algorithm for finding frequent patterns.

1. Find all frequent sets of magnitude k.
2. Out of those, form all sets of magnitude k+1.
3. Find all frequent sets of magnitude k+1.

### Metrics

data | ab | ¬ab | a¬b | ¬a¬b | AllConf | Jaccard | Cosine | Kulc | MaxConf
-----|----|-----|-----|------|---------|---------|--------|------|--------
D1 | 10,000 | 1,000 | 1,000 | 100,000 | 0.91 | 0.83 | 0.91 | 0.91 | 0.91
D2 | 10,000 | 1,000 | 1,000 | 100 | 0.91 | 0.83 | 0.91 | 0.91 | 0.91
D3 | 100 | 1,000 | 1,000 | 100,000 | 0.09 | 0.05 | 0.09 | 0.09 | 0.09
D4 | 1,000 | 1,000 | 1,000 | 100,000 | 0.09 | 0.09 | 0.29 | 0.5 | 0.91
D5 | 1,000 | 10 | 100,000 | 100,000 | 0.01 | 0.01 | 0.10 | 0.5 | 0.99
#### Non-Null Invariant Metrics
##### Lift
##### Χ^2
#### Null-Invariant Metrics
##### AllConf
##### Jaccard
##### Cosine
##### Kulc
##### MaxConf
