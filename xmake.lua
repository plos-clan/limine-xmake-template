set_project("ExampleOS")

add_rules("mode.debug", "mode.release")
add_requires("zig")

set_arch("x86_64")
set_warnings("all", "extra", "pedantic", "error")

set_policy("run.autobuild", true)
set_policy("check.auto_ignore_flags", false)

target("kernel")
    set_kind("binary")
    set_languages("c23")
    set_toolchains("@zig")
    set_default(false)

    if is_mode("debug") then
        set_optimize("g") 
    else 
        set_optimize("fastest")
        set_policy("build.optimization.lto", true)
    end

    add_includedirs("include")
    add_files("src/**.c")

    add_cflags("-target x86_64-freestanding")
    add_cflags("-m64", "-mno-red-zone", "-nostdinc", "-fno-builtin")
    add_cflags("-mcmodel=kernel", "-fno-stack-protector")
    add_cflags("-mno-80387", "-mno-mmx", "-mno-sse", "-mno-sse2")

    add_ldflags("-target x86_64-freestanding")
    add_ldflags("-nostdlib", "-T assets/linker.ld")

target("iso")
    set_kind("phony")
    add_deps("kernel")
    set_default(true)

    on_build(function (target)
        import("core.project.config")
        import("core.project.project")

        local build_root = config.builddir()
        local iso_dir = path.join(build_root, "iso")
        local iso_file = path.join(build_root, "ExampleOS.iso")

        os.mkdir(path.join(iso_dir, "limine"))
        os.cp("assets/limine/*", path.join(iso_dir, "limine/"))

        local target = project.target("kernel")
        os.cp(target:targetfile(), path.join(iso_dir, "kernel.elf"))

        local xorriso_args = {
            "-as", "mkisofs",
            "-R", "-r", "-J",
            "--efi-boot", "limine/limine-uefi-cd.bin",
            "-no-emul-boot",
            "-efi-boot-part",
            "--efi-boot-image",
            "--protective-msdos-label",
            "-o", iso_file,
            iso_dir
        }

        os.runv("xorriso", xorriso_args)
        print("ISO image created at: %s", iso_file)
    end)

    on_run(function (target)
        import("core.project.config")

        local flags = {
            "-M", "q35",
            "-cpu", "qemu64,+x2apic",
            "-smp", "4",
            "-drive", "if=pflash,format=raw,file=assets/ovmf-code.fd",
            "-cdrom", config.builddir() .. "/ExampleOS.iso"
        }

        os.runv("qemu-system-x86_64", flags)
    end)
