#!/usr/bin/env bash

export ConnectionStrings__Database="Host=localhost:5432; Database=$1; Username=postgres; Password=postgres"

echo -e "[1/5]\tsetting connection string..."
export ConnectionStrings__Database="Host=localhost:5432; Database=$1; Username=postgres; Password=postgres"
echo $ConnectionStrings__Database

echo -e '\n[2/5]\tdropping database...'
dotnet-ef database drop -f

echo -e '\n[3/5]\tremoving migration...'
# dotnet-ef migrations remove
rm -f ./Migrations/*_Init*.cs
rm -f ./Migrations/*Snapshot*.cs

echo -e '\n[4/5]\tcreating migration...'
dotnet-ef migrations add Init

echo -e '\n[5/5]\tupdating database...'
dotnet-ef database update
