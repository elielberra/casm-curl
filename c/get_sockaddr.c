#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>
#include <string.h>

// struct sockaddr get_sockaddr() {

// }

struct url_parts {
  char domain[64];
  char port[6];
};

CURLUcode get_url_parts(const char *url_content, struct url_parts *url_data) {
  CURLUcode result_code;
  CURLU *url = curl_url();
  result_code = curl_url_set(url, CURLUPART_URL, url_content, CURLU_DEFAULT_SCHEME);
  if (result_code) {
    return result_code;
  }
  char *url_host;
  result_code = curl_url_get(url, CURLUPART_HOST, &url_host, 0);
  if (result_code) {
    return result_code;
  }
  snprintf(url_data->domain, sizeof(url_data->domain), "%s", url_host);
  curl_free(url_host);
  char *url_port;
  result_code = curl_url_get(url, CURLUPART_PORT, &url_port, CURLU_DEFAULT_PORT);
  if (result_code) {
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
  if (result_code != CURLUE_OK) {
    printf("error\n");
    fprintf(stderr, "Error: %s (code %i)\n", curl_url_strerror(result_code), result_code);
    return EXIT_FAILURE;
  }
  printf("Domain is %s\n", processed_url.domain);
  printf("Port is %s\n", processed_url.port);
  return EXIT_SUCCESS;
}