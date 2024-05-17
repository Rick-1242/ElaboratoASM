// This is the blueprint
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    if (argc < 2 || argc > 3)
    {
        printf("Too many arguments supplied.\n");
        exit(-1);
    }
}