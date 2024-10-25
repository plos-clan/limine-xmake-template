set_project("limineOS")

add_rules("mode.debug", "mode.release")

set_optimize("fastest")
set_warnings("all", "error")
set_policy("build.optimization.lto", true)

target("kernel")
    set_kind("binary")
    set_languages("c23")
    set_toolchains("gcc")

    add_includedirs("include")
    add_files("src/*.c")

    add_cflags("-m64", "-mno-mmx", "-mno-sse", "-mno-red-zone", {force = true})
    add_ldflags("-nostdlib", "-T", "assets/linker.ld", {force = true})

target("iso")
    set_kind("phony")
    add_deps("kernel")
    set_default(true)

    on_build(function (target)
        import("core.project.project")

        local iso_dir = "$(buildir)/iso"
        os.cp("assets/limine", iso_dir .. "/limine")

        local target = project.target("kernel")
        os.cp(target:targetfile(), iso_dir .. "/kernel.elf")

        local iso_file = "$(buildir)/template.iso"
        os.run("xorriso -as mkisofs --efi-boot limine/limine-uefi-cd.bin %s -o %s", iso_dir, iso_file)
        print("ISO image created at: " .. iso_file)
    end)

target("qemu")
    set_kind("phony")
    add_deps("iso")
    set_default(false)

    on_build(function (target)
        local flags = "-M q35 -drive if=pflash,format=raw,file=assets/ovmf-code.fd"
        os.run("qemu-system-x86_64 %s -cdrom $(buildir)/template.iso", flags)
    end)