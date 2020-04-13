#!/bin/bash

#Formatting *sonnet files

cd lib/deeployer
jsonnetfmt -i docker-compose-generator.libsonnet
jsonnetfmt -i resource_generator.libsonnet


cd ../../tests/docker-compose-prod
 python3 -m json.tool host.json hos.json
 rm host.json 
 mv hos.json host.json

 python3 -m json.tool no_host.json no_hos.json
 rm no_host.json 
 mv no_hos.json no_host.json

# Getting back to root

# test-demo json files
# cat jsonnetfile.json
# python3 -m json.tool jsonnetfile.json jsonnetfile.json
# cat jsonnetfile.json


cd ../../tests/schema
 python3 -m json.tool valid.json vali.json
 rm valid.json 
 mv vali.json valid.json
 
 python3 -m json.tool invalid_container_definition_with_unknown_properties.json invalid_container_definition_with_unknown_propertie.json
 rm invalid_container_definition_with_unknown_properties.json  
 mv invalid_container_definition_with_unknown_propertie.json invalid_container_definition_with_unknown_properties.json

 python3 -m json.tool invalid_container_definition_without_image.json invalid_container_definition_without_imag.json 
  rm invalid_container_definition_without_image.json 
 mv invalid_container_definition_without_imag.json invalid_container_definition_without_image.json

 python3 -m json.tool invalid_container_with_wrong_declared_envVars.json invalid_container_with_wrong_declared_envVar.json 
 rm invalid_container_with_wrong_declared_envVars.json 
 mv invalid_container_with_wrong_declared_envVar.json invalid_container_with_wrong_declared_envVars.json

 python3 -m json.tool invalid_test_testing_envVars_with_a_specialObject.json invalid_test_testing_envVars_with_a_specialObjec.json
  rm invalid_test_testing_envVars_with_a_specialObject.json
 mv invalid_test_testing_envVars_with_a_specialObjec.json invalid_test_testing_envVars_with_a_specialObject.json

 python3 -m json.tool invalid_test_testing_envVars_with_nonStringValue.json invalid_test_testing_envVars_with_nonStringValu.json
  rm invalid_test_testing_envVars_with_nonStringValue.json 
 mv invalid_test_testing_envVars_with_nonStringValu.json invalid_test_testing_envVars_with_nonStringValue.json 

 python3 -m json.tool invalid_properties_definition_with_emptyString_in_image.json invalid_properties_definition_with_emptyString_in_imag.json
  rm invalid_properties_definition_with_emptyString_in_image.json
 mv invalid_properties_definition_with_emptyString_in_imag.json invalid_properties_definition_with_emptyString_in_image.json

 python3 -m json.tool invalid_properties_definition_with_emptyString_in_max_cpu.json invalid_properties_definition_with_emptyString_in_max_cp.json
  rm invalid_properties_definition_with_emptyString_in_max_cpu.json 
 mv invalid_properties_definition_with_emptyString_in_max_cp.json invalid_properties_definition_with_emptyString_in_max_cpu.json 

 python3 -m json.tool invalid_properties_definition_with_emptyString_in_min_cpu.json invalid_properties_definition_with_emptyString_in_min_cp.json
  rm invalid_properties_definition_with_emptyString_in_min_cpu.json
 mv invalid_properties_definition_with_emptyString_in_min_cp.json invalid_properties_definition_with_emptyString_in_min_cpu.json

 python3 -m json.tool invalid_properties_definition_with_emptyString_in_max_memory.json invalid_properties_definition_with_emptyString_in_max_memor.json
  rm invalid_properties_definition_with_emptyString_in_max_memory.json
 mv invalid_properties_definition_with_emptyString_in_max_memor.json invalid_properties_definition_with_emptyString_in_max_memory.json

 python3 -m json.tool invalid_properties_definition_with_emptyString_in_min_memory.json invalid_properties_definition_with_emptyString_in_min_memor.json
  rm invalid_properties_definition_with_emptyString_in_min_memory.json
 mv invalid_properties_definition_with_emptyString_in_min_memor.json invalid_properties_definition_with_emptyString_in_min_memory.json


cd ../..
jsonnetfmt -i deeployer.libsonnet

cd environments/default/
 python3 -m json.tool spec.json spe.json
 rm spec.json 
 mv spe.json spec.json

# cd ../../scripts/
#  python3 -m json.tool jsonnetfile.json jsonnetfil.json
#  rm jsonnetfile.json 
#  mv jsonnetfil.json jsonnetfile.json

cd ../../
 python3 -m json.tool jsonnetfile.lock.json jsonnetfile.lock.jso
 rm jsonnetfile.lock.json 
 mv jsonnetfile.lock.jso jsonnetfile.lock.json

 python3 -m json.tool jsonnetfile.json jsonnetfil.json
 rm jsonnetfile.json 
 mv jsonnetfil.json jsonnetfile.json




