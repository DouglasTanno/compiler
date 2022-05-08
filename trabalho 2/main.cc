#include <string>
#include <iostream>
#include <unistd.h>

#include "driver.hh"

int main(int argc, char **argv) {
  std::string filename;
  int opt;
  while ((opt = getopt(argc, argv, "i:?")) != EOF)
      switch(opt) {
          case 'i': filename = optarg; break;
          case '?': std::cerr << "Usuage: tc -i <filename>" << std::endl; break;
          default: std::cerr << std::endl; abort();
      }

  Simples::Driver driver;
  driver.parse_file(filename);
  return 0;
}
