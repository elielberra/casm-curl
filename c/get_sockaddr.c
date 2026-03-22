#define _POSIX_C_SOURCE 200112L
#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>
#include <string.h>
#include <netdb.h>

struct url_parts {
  char domain[64];
  char port[6];
};

int get_sockaddr(struct url_parts *url_data, struct sockaddr *sockaddr_data) {
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

void print_curl_url_err(CURLUcode result_code) {
  fprintf(stderr, "Error: %s (code %i)\n", curl_url_strerror(result_code), result_code);
}

CURLUcode get_url_parts(const char *url_content, struct url_parts *url_data) {
  CURLUcode result_code;
  CURLU *url = curl_url();
  result_code = curl_url_set(url, CURLUPART_URL, url_content, CURLU_DEFAULT_SCHEME);
  if (result_code) {
    print_curl_url_err(result_code);
    return result_code;
  }
  char *url_host;
  result_code = curl_url_get(url, CURLUPART_HOST, &url_host, 0);
  if (result_code) {
    print_curl_url_err(result_code);
    return result_code;
  }
  snprintf(url_data->domain, sizeof(url_data->domain), "%s", url_host);
  curl_free(url_host);
  char *url_port;
  result_code = curl_url_get(url, CURLUPART_PORT, &url_port, CURLU_DEFAULT_PORT);
  if (result_code) {
    print_curl_url_err(result_code);
    return result_code;
  }
  snprintf(url_data->port, sizeof(url_data->port), "%s", url_port);
  curl_free(url_port);
  curl_url_cleanup(url);
  return 0;
} 

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: %s <URL>\n", argv[0]);
    return EXIT_FAILURE;
  }
  const char *user_url = argv[1];
  struct url_parts processed_url;
  CURLUcode result_code = get_url_parts(user_url, &processed_url);
  if (result_code != CURLUE_OK) return EXIT_FAILURE;
  struct sockaddr result;
  int rc = get_sockaddr(&processed_url, &result);
  if (rc) EXIT_FAILURE;
  return EXIT_SUCCESS;
}