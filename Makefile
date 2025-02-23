CC=clang
CFLAGS=-g -Werror -Wall -Wstrict-prototypes -Wundef -Wmissing-declarations -Wmissing-prototypes -std=gnu17 -ggdb3 -fsanitize=address
SRCS=reverse.c
TARGET=reverse

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@

# Run the end to end (e2e) tests.
e2e-tests: $(TARGET)
	@./utils/e2e-tests.sh

.PHONY: clean
clean:
	rm -f $(TARGET)

submission: $(TARGET)
	@read -p "Enter your Mines multipass username: " USERNAME && \
	zip -r "$${USERNAME}-submission.zip" ./Makefile ./reverse.c ./override.token
