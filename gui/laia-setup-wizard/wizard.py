#!/usr/bin/env python3
"""
LAIA First-Run Setup Wizard
Guides new users through initial configuration.
Designed for Windows users — minimal jargon, clear choices.
"""
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import subprocess
import threading
import os


class SetupWizard(Gtk.Assistant):
    def __init__(self):
        super().__init__()
        self.set_title("LAIA Setup Wizard")
        self.set_default_size(600, 450)
        self.connect("apply", self._on_apply)
        self.connect("cancel", Gtk.main_quit)
        self.connect("close", Gtk.main_quit)

        self._selected_models = []
        self._install_ai = True

        self._add_welcome_page()
        self._add_hardware_page()
        self._add_ai_page()
        self._add_security_page()
        self._add_confirm_page()
        self._add_progress_page()

    def _add_welcome_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16, border_width=20)

        title = Gtk.Label()
        title.set_markup("<big><b>👋 Welcome to LAIA Linux</b></big>")
        box.pack_start(title, False, False, 0)

        desc = Gtk.Label()
        desc.set_markup(
            "This wizard will set up your LAIA system in a few minutes.\n\n"
            "LAIA includes:\n"
            "  🤖  <b>Local AI models</b> — run AI privately on your computer\n"
            "  🔒  <b>Security hardening</b> — protected by default\n"
            "  🛠️  <b>OpenClaw</b> — AI assistant with strict security controls\n\n"
            "Click <b>Next</b> to begin."
        )
        desc.set_line_wrap(True)
        desc.set_justify(Gtk.Justification.LEFT)
        box.pack_start(desc, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.INTRO)
        self.set_page_title(box, "Welcome")
        self.set_page_complete(box, True)

    def _add_hardware_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        # Detect RAM
        try:
            ram_line = open("/proc/meminfo").readline()
            ram_kb = int(ram_line.split()[1])
            self._ram_gb = ram_kb // (1024 * 1024)
        except Exception:
            self._ram_gb = 8

        # Determine tier message
        if self._ram_gb < 8:
            tier_msg = "⚠️ Limited RAM. Only very small AI models will run well."
            tier_color = "orange"
        elif self._ram_gb < 16:
            tier_msg = "✅ Good for compact AI models (3B–7B range)."
            tier_color = "green"
        elif self._ram_gb < 32:
            tier_msg = "✅ Good hardware — most models will run well."
            tier_color = "green"
        else:
            tier_msg = "🚀 Powerful hardware — full model library available!"
            tier_color = "green"

        info = Gtk.Label()
        info.set_markup(
            f"<b>Your system:</b>\n"
            f"  RAM: <b>{self._ram_gb} GB</b>\n\n"
            f"{tier_msg}"
        )
        info.set_xalign(0)
        box.pack_start(info, False, False, 0)

        # Show disk space
        try:
            result = subprocess.run(
                ["df", "-BG", "/"],
                capture_output=True, text=True
            )
            lines = result.stdout.strip().split("\n")
            if len(lines) > 1:
                parts = lines[1].split()
                free_gb = parts[3].replace("G", "")
                disk_info = Gtk.Label()
                disk_info.set_markup(f"  Disk (free): <b>{free_gb} GB</b>")
                disk_info.set_xalign(0)
                box.pack_start(disk_info, False, False, 0)

                if int(free_gb) < 10:
                    warn = Gtk.Label()
                    warn.set_markup("⚠️ Low disk space. AI models need 2–20GB. Consider installing fewer models.")
                    warn.set_line_wrap(True)
                    warn.set_xalign(0)
                    box.pack_start(warn, False, False, 0)
        except Exception:
            pass

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "Hardware Check")
        self.set_page_complete(box, True)

    def _add_ai_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Choose AI Models to Install</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        desc = Gtk.Label(
            label="These models run entirely on your computer — no internet needed after download."
        )
        desc.set_line_wrap(True)
        desc.set_xalign(0)
        box.pack_start(desc, False, False, 0)

        # Select models based on detected RAM
        ram = getattr(self, "_ram_gb", 8)
        if ram < 8:
            models = [
                ("gemma3:1b", "Gemma 3 (1B) — Google's newest, ultra-fast", "~0.8 GB", True),
                ("gemma3:4b", "Gemma 3 (4B) — Best small model (2026)", "~2.5 GB", False),
            ]
        elif ram < 16:
            models = [
                ("gemma3:4b", "Gemma 3 (4B) — Google's best compact model (2026)", "~2.5 GB", True),
                ("phi4-mini", "Phi-4 Mini — Great for coding tasks", "~2.5 GB", True),
                ("llama3.2:3b", "Llama 3.2 (3B) — Meta's model, well-rounded", "~2.0 GB", False),
                ("deepseek-r1:7b", "DeepSeek R1 (7B) — Strong reasoning model", "~4.7 GB", False),
            ]
        else:
            models = [
                ("gemma3:4b", "Gemma 3 (4B) — Google's best compact model (2026)", "~2.5 GB", True),
                ("phi4-mini", "Phi-4 Mini — Great for coding tasks", "~2.5 GB", True),
                ("deepseek-r1:7b", "DeepSeek R1 (7B) — Strong reasoning model", "~4.7 GB", True),
                ("qwen2.5-coder:7b", "Qwen 2.5 Coder (7B) — Best coding model", "~4.7 GB", False),
                ("qwen3:8b", "Qwen 3 (8B) — Alibaba's latest with thinking mode", "~5.2 GB", False),
            ]

        self._model_checks = {}
        for model_id, label, size, default in models:
            row = Gtk.Box(spacing=8)
            cb = Gtk.CheckButton(label=f"{label}  [{size}]")
            cb.set_active(default)
            self._model_checks[model_id] = cb
            row.pack_start(cb, True, True, 0)
            box.pack_start(row, False, False, 0)

        no_ai = Gtk.CheckButton(label="Skip AI installation (I'll do it later)")
        no_ai.connect("toggled", self._on_no_ai_toggled)
        box.pack_end(no_ai, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "AI Models")
        self.set_page_complete(box, True)

    def _on_no_ai_toggled(self, cb):
        self._install_ai = not cb.get_active()

    def _add_security_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>🔒 Security Settings</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        desc = Gtk.Label(
            label="LAIA applies strict security settings by default. "
                  "All settings can be changed later in the Security Configurator."
        )
        desc.set_line_wrap(True)
        desc.set_xalign(0)
        box.pack_start(desc, False, False, 0)

        settings = [
            "✅ Firewall enabled (blocks all incoming connections)",
            "✅ Automatic security updates",
            "✅ AppArmor enabled (restricts application access)",
            "✅ OpenClaw in restricted mode (always asks permission)",
            "✅ Ollama accessible from this computer only",
        ]

        for s in settings:
            label = Gtk.Label(label=s, xalign=0)
            box.pack_start(label, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "Security")
        self.set_page_complete(box, True)

    def _add_confirm_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        label = Gtk.Label()
        label.set_markup(
            "<b>Ready to install!</b>\n\n"
            "Click <b>Apply</b> to begin installation.\n"
            "This may take 10-30 minutes depending on your internet speed.\n\n"
            "Your computer will NOT restart automatically."
        )
        label.set_line_wrap(True)
        box.pack_start(label, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONFIRM)
        self.set_page_title(box, "Confirm")
        self.set_page_complete(box, True)

    def _add_progress_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        self.progress_label = Gtk.Label(label="Starting installation...")
        box.pack_start(self.progress_label, False, False, 0)

        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_show_text(True)
        box.pack_start(self.progress_bar, False, False, 0)

        self.log_view = Gtk.TextView()
        self.log_view.set_editable(False)
        self.log_view.set_monospace(True)
        sw = Gtk.ScrolledWindow()
        sw.add(self.log_view)
        sw.set_vexpand(True)
        box.pack_start(sw, True, True, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.PROGRESS)
        self.set_page_title(box, "Installing...")
        self._progress_page = box

    def _on_apply(self, assistant):
        selected = [mid for mid, cb in self._model_checks.items() if cb.get_active()]
        threading.Thread(
            target=self._run_installation,
            args=(selected,),
            daemon=True
        ).start()

    def _run_installation(self, models):
        steps = [
            ("Applying security hardening...", "sudo bash /opt/laia/config/security/harden.sh"),
            ("Configuring OpenClaw...", "bash /opt/laia/config/openclaw/setup-restricted.sh"),
        ]
        if self._install_ai and models:
            models_arg = " ".join(models)
            steps.append(("Installing Ollama...", "sudo bash /opt/laia/config/ai/install-ollama.sh"))
            steps.append(("Downloading AI models...", f"bash /opt/laia/config/ai/install-models.sh {models_arg}"))
            steps.append(("Installing OpenWebUI...", "sudo bash /opt/laia/config/ai/install-openwebui.sh"))

        for i, (msg, cmd) in enumerate(steps):
            GLib.idle_add(self.progress_label.set_text, msg)
            GLib.idle_add(self.progress_bar.set_fraction, i / len(steps))
            result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)
            log_text = f"$ {cmd}\n{result.stdout}\n{result.stderr}\n"
            GLib.idle_add(self.log_view.get_buffer().insert_at_cursor, log_text)

        GLib.idle_add(self.progress_bar.set_fraction, 1.0)
        GLib.idle_add(self.progress_label.set_text, "✅ Installation complete!")
        GLib.idle_add(self.set_page_complete, self._progress_page, True)


def main():
    wizard = SetupWizard()
    wizard.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
