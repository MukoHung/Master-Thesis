:: Basic Syntax

if (condition) dosomething

:: For if..else if
if (condition) (statement1) else (statement2)

SET /A a=2
SET /A b=3
SET name1=Aston
SET name2=Martin

:: Using if statement
IF %a%==2 echo The value of a is 2
IF %name2%==Martin echo Hi this is Martin

:: Using if else statements
IF %a%==%b% (echo Numbers are equal) ELSE (echo Numbers are different)
IF %name1%==%name2% (echo Name is Same) ELSE (echo Name is different)
PAUSE


:: Example to check if a variable is defined or not
@echo OFF

::If var is not defined SET var = hello
IF "%var%"=="" (SET var=Hello)

:: This can be done in this way as well
IF NOT DEFINED var (SET var=Hello)

:: Example to check if a file exists or not

@echo OFF

::EXIST command is used to check for existence
IF EXIST D:\abc.txt ECHO abc.txt found
IF EXIST D:\xyz.txt (ECHO xyz.txt found) ELSE (ECHO xyz.txt not found)

PAUSE

@echo off 
setlocal enabledelayedexpansion 
set topic[0] = comments 
set topic[1] = variables 
set topic[2] = Arrays 
set topic[3] = Decision making 
set topic[4] = Time and date 
set topic[5] = Operators 

for /l %%n in (0,1,5) do ( 
   echo !topic[%%n]! 
)