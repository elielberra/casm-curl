CC=clang
CC_FLAGS=-g

# all: getip

# %: %.c
# 	$(CC) $(CC_FLAGS) -o $@ $^

all: get_ip get_domain get_sockaddr.o

get_ip: get_ip.c
	$(CC) $(CC_FLAGS) -o $@ $^

get_domain: get_domain.c
	$(CC) $(CC_FLAGS) -o $@ $^ -lcurl

get_sockaddr.o: get_sockaddr.c
	$(CC) $(CC_FLAGS) -c -o $@ $^

clean:
	rm -rf *.dSYM get_ip get_domain get_sockaddr
