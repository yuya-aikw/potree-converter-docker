# About
- Self-Contained Docker Environment for [PotreeConverter 2.0](https://github.com/potree/PotreeConverter.git)

# Usage
1. Build docker image
~~~bash
docker build . -t potree-converter
~~~
2. Fix `run_script.sh`
~~~run_script.sh
docker run --rm\
 -v "<path to your data dir>:/data"\
  potree-converter -i <your input point cloud file> -o <your output dir>
~~~
- ex.
~~~
"""
/data_dir/    #<path to your data dir>
├── input.las # <your input point cloud file (.las or .laz)>
└── output/   # <your output dir>
    ├── hierarchy.bin
    ├── log.txt
    ├── metadata.json
    └── octree.bin
"""

docker run --rm\
 -v "/data_dir:/data"\
  potree-converter -i input.las -o output
~~~

3. Run `run_script.sh`
~~~bash
source run_script.sh
~~~

# Docker Image
## Stage 1 (Build PotreeConverter)
- base: ubuntu:22.04
## State 2 (Run PotreeConverter)
- base: ubuntu:22.04
