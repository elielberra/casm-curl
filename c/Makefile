CC=clang
CC_FLAGS=-g

# all: getip

# %: %.c
# 	$(CC) $(CC_FLAGS) -o $@ $^

all: get_ip get_domain

get_ip: get_ip.c
	$(CC) $(CC_FLAGS) -o $@ $^

get_domain: get_domain.c
	$(CC) $(CC_FLAGS) -o $@ $^ -lcurl

clean:
	rm -rf *.dSYM get_ip get_domain
