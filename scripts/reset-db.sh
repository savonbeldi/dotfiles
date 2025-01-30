#!/usr/bin/env bash


echo -e "[1/3]\tsetting connection string..."
export ConnectionStrings__Database="Host=localhost:5432; Database=$1; Username=postgres; Password=postgres"
echo $ConnectionStrings__Database

echo -e "\n[2/3]\tdropping database..."
dotnet-ef database drop -f

echo -e "\n[3/3]\tupdating database..."
dotnet-ef database update
