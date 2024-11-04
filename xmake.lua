set_project("ExampleOS")

add_rules("mode.debug", "mode.release")

set_optimize("fastest")
set_warnings("all", "extra")

set_policy("run.autobuild", true)
set_policy("build.optimization.lto", true)

target("kernel")
    set_kind("binary")
    set_languages("c23")
    set_toolchains("clang")
    set_default(false)

    add_includedirs("include")
    add_files("src/**.c")

    add_cflags("-m64", "-mno-red-zone", {force = true})
    add_cflags("-mno-80387", "-mno-mmx", "-mno-sse", "-mno-sse2", {force = true})
    add_ldflags("-nostdlib", "-static", "-T", "assets/linker.ld", {force = true})

target("iso")
    set_kind("phony")
    add_deps("kernel")
    set_default(true)

    on_build(function (target)
        import("core.project.project")

        local iso_dir = "$(buildir)/iso"
        os.cp("assets/limine/*", iso_dir .. "/limine/")

        local target = project.target("kernel")
        os.cp(target:targetfile(), iso_dir .. "/kernel.elf")

        local iso_file = "$(buildir)/ExampleOS.iso"
        os.run("xorriso -as mkisofs --efi-boot limine/limine-uefi-cd.bin %s -o %s", iso_dir, iso_file)
        print("ISO image created at: %s", iso_file)
    end)

    on_run(function (target)
        import("core.project.config")

        local flags = {
            "-M", "q35",
            "-cpu", "qemu64,+x2apic",
            "-smp", "4",
            "-drive", "if=pflash,format=raw,file=assets/ovmf-code.fd",
            "-cdrom", config.buildir() .. "/ExampleOS.iso"
        }
        
        os.runv("qemu-system-x86_64", flags)
    end)
