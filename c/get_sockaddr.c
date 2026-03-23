#define _POSIX_C_SOURCE 200112L
#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>
#include <string.h>
#include <netdb.h>

typedef struct {
  char domain[64];
  char port[6];
} url_parts_t;

int domain_to_sockaddr(url_parts_t *url_data, struct sockaddr *sockaddr_data) {
  struct addrinfo hint;
  struct addrinfo *result;
  memset(&hint, 0, sizeof(hint));
  hint.ai_family = AF_INET;
  hint.ai_socktype = SOCK_STREAM;
  int status = getaddrinfo(url_data->domain, url_data->port, &hint, &result);
  if (status) {
    fprintf(stderr, "Error: %s (code %i)\n", gai_strerror(status), status);
    return status;
  }
  memcpy(sockaddr_data, (struct sockaddr_in*)result->ai_addr, sizeof(struct sockaddr));
  freeaddrinfo(result);
  return 0;
}

void print_curl_url_err(CURLUcode rc) {
  fprintf(stderr, "Error: %s (code %i)\n", curl_url_strerror(rc), rc);
}

CURLUcode get_url_parts(const char *url_content, url_parts_t *url_data) {
  CURLUcode rc;
  CURLU *url = curl_url();
  rc = curl_url_set(url, CURLUPART_URL, url_content, CURLU_DEFAULT_SCHEME);
  if (rc) {
    print_curl_url_err(rc);
    return rc;
  }
  char *url_host;
  rc = curl_url_get(url, CURLUPART_HOST, &url_host, 0);
  if (rc) {
    print_curl_url_err(rc);
    return rc;
  }
  snprintf(url_data->domain, sizeof(url_data->domain), "%s", url_host);
  curl_free(url_host);
  char *url_port;
  rc = curl_url_get(url, CURLUPART_PORT, &url_port, CURLU_DEFAULT_PORT);
  if (rc) {
    print_curl_url_err(rc);
    return rc;
  }
  snprintf(url_data->port, sizeof(url_data->port), "%s", url_port);
  curl_free(url_port);
  curl_url_cleanup(url);
  return 0;
}

struct sockaddr* get_sockaddr(const char *unprocessed_url){
  url_parts_t processed_url;
  if (get_url_parts(unprocessed_url, &processed_url) != 0)
    return (struct sockaddr*)-1;
  struct sockaddr *remote_addr = malloc(sizeof(struct sockaddr));
  if (!remote_addr) return (struct sockaddr*)-1;
  if (domain_to_sockaddr(&processed_url, remote_addr) != 0){
    free(remote_addr);
    return (struct sockaddr*)-1;
  }
  return remote_addr;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: %s <URL>\n", argv[0]);
    return EXIT_FAILURE;
  }
  const char *user_url = argv[1];
  struct sockaddr *sock;
  sock = get_sockaddr(user_url);
}