#!/bin/bash

generate_dir="L1_memcpy_tasks"
compile_dir="L1_memcpy_tasks_compile"
outpath=$1

rm -rf ${generate_dir}
mkdir -p ${generate_dir}
rm -rf ${outpath}
mkdir -p ${outpath}
rm -rf ${compile_dir}
mkdir -p ${compile_dir}

pushd ${compile_dir}
mbed new .
popd

# Generate directories for 10, 100, 1000, 10000, 100000 byte read/write
python3 benchmarks/src/generate.py --tier L1 --task ReadBytesTask --output-path ${generate_dir} --nbytes "[10,100,1000,10000,100000,50000,1000000]" 

for i in 10 100 1000 10000 50000 100000; do

    # Compile and run
    dirpath="${generate_dir}/ReadBytesTask/nbytes=${i}/"
    python3 benchmarks/scripts/compile_programs.py --target ${dirpath} --mbed-program-dir ${compile_dir}
    python3 benchmarks/scripts/run_on_mcu.py --target ${dirpath} --timelimit 10 --output_path ${dirpath}/run_output
    tail -n 1 ${dirpath}/run_output > ${dirpath}/stats.json
    cp ${dirpath}/stats.json ${outpath}/ReadBytesTask_nbytes=${i}.json
done