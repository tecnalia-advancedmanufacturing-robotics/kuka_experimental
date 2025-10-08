#!/bin/bash
find visual -type f \( -iname "*.dae" -o -iname "*.stl" \) -print0 | while read -rd $'\0' MESH
do
    OUTFILE=$(echo "${MESH}" | cut -d'/' -f2- | cut -d'.' -f1)
    CMD="meshlabserver -i ${MESH} -o collision/${OUTFILE}.stl -s script.mlx"
    echo "${CMD}"
    eval "${CMD}"
done

# rosrun moveit_setup_assistant collisions_updater --srdf $(rospack find kr20r1810_moveit_config)/config/kuka_kr20.srdf --urdf $(rospack find kuka_kr20_support)/urdf/kr20r1810_2.xacro   --default --always --trials 100000 --verbose