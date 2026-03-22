#define _POSIX_C_SOURCE 200112L
#include <stdlib.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  if(argc != 2) {
    printf("Usage: %s <hostname>\n", argv[0]);
    return EXIT_FAILURE;
  }
  const char * hostname = argv[1];
  struct addrinfo hint;
  struct addrinfo *result;
  memset(&hint, 0, sizeof(hint));
  hint.ai_family = AF_INET;
  hint.ai_socktype = SOCK_STREAM;    // Retrieve schema from get_domain instead of hardcoding
  int status = getaddrinfo(hostname, "https", &hint, &result);
  if (status) {
    printf("getaddrinfo failed with status code %i!\n", status);
    return EXIT_FAILURE;
  }
  struct addrinfo *tmp = result;
  while (tmp != NULL){
    printf("Entry:\n");
    printf("\tType: %i\n", tmp->ai_socktype);
    printf("\tFamily: %i\n", tmp->ai_family);
    char address_string[INET_ADDRSTRLEN];
    void *raw_addr;
    raw_addr = &((struct sockaddr_in*)tmp->ai_addr)->sin_addr;
    printf("\tAddress binary: %p\n", raw_addr);
    inet_ntop(tmp->ai_family, raw_addr, address_string, INET_ADDRSTRLEN);
    printf("\tAddress string: %s\n", address_string);
    const int PORT_LEN = 6;
    char port_string[PORT_LEN];
    uint16_t raw_port;
    raw_port = ((struct sockaddr_in*)tmp->ai_addr)->sin_port;
    uint16_t host_port = ntohs(raw_port);
    printf("\tPort string: %u\n", host_port);
    sprintf(port_string, "%u", host_port);
    tmp = tmp->ai_next;
  }
  freeaddrinfo(result);
  return EXIT_SUCCESS;
}

