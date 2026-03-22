#include <stdlib.h>
#include <stdio.h>
#include <curl/curl.h>

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: %s <URL>\n", argv[0]);
    return EXIT_FAILURE;
  }
  const char * url_content = argv[1];
  CURLUcode result_code;
  CURLU *url = curl_url();

  result_code = curl_url_set(url, CURLUPART_URL, url_content, 0);
  if (result_code) {
    printf("Error code %i while trying to set the url %s\n", result_code, url_content);
    return EXIT_FAILURE;
  }
  char *url_host;
  result_code = curl_url_get(url, CURLUPART_HOST, &url_host, 0);
  if (result_code) {
    printf("Error code %i while trying to get the url %s\n", result_code, url_content);
  }
  printf("The host is %s\n", url_host);
  curl_free(url_host);

  char *url_port;
  result_code = curl_url_get(url, CURLUPART_PORT, &url_port, CURLU_DEFAULT_PORT);
  if (result_code) {
    printf("Error code %i while trying to get the port %s\n", result_code, url_content);
  }
  printf("The port is %s\n", url_port);
  curl_free(url_port);

  curl_url_cleanup(url);
  return EXIT_SUCCESS;
}
