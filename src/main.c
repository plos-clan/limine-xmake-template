#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>
#include <limine.h>

__attribute__((used, section(".limine_requests")))
static volatile LIMINE_BASE_REVISION(3);

__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request framebuffer_request = {
    .id = LIMINE_FRAMEBUFFER_REQUEST,
    .revision = 0
};

__attribute__((used, section(".limine_requests_start")))
static volatile LIMINE_REQUESTS_START_MARKER;

__attribute__((used, section(".limine_requests_end")))
static volatile LIMINE_REQUESTS_END_MARKER;

void kmain(void) {
    if (LIMINE_BASE_REVISION_SUPPORTED == false) {
        for (;;) __asm__ ("hlt");
    }

    if (framebuffer_request.response == NULL
     || framebuffer_request.response->framebuffer_count < 1) {
        for (;;) __asm__ ("hlt");
    }

    struct limine_framebuffer *framebuffer = framebuffer_request.response->framebuffers[0];

    uint64_t width = framebuffer->width;
    uint64_t height = framebuffer->height;

    uint64_t stride = framebuffer->pitch / 4;
    uint32_t *buffer = framebuffer->address;

    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            buffer[y * stride + x] = (x * 255 / width) << 16 | (y * 255 / height) << 8;
        }
    }

    for (;;) __asm__ ("hlt");
}
