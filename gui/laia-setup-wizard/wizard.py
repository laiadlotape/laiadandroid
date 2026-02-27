#!/usr/bin/env python3
"""
LAIA First-Run Setup Wizard
Guides new users through AI mode selection and configuration.
Online-free first, with local and LAN options.
"""
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
import subprocess
import threading
import os
import json


class SetupWizard(Gtk.Assistant):
    def __init__(self):
        super().__init__()
        self.set_title("LAIA Setup Wizard")
        self.set_default_size(700, 550)
        self.connect("apply", self._on_apply)
        self.connect("cancel", Gtk.main_quit)
        self.connect("close", Gtk.main_quit)

        self.mode = None
        self.provider = None
        self.api_key = None
        self.lan_host = None
        self.lan_port = 11434
        
        self._add_welcome_page()
        self._add_mode_page()
        self._add_online_provider_page()
        self._add_local_hardware_page()
        self._add_lan_remote_page()
        self._add_summary_page()
        self._add_progress_page()

    def _add_welcome_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20, border_width=20)

        title = Gtk.Label()
        title.set_markup("<big><b>👋 Welcome to LAIA</b></big>")
        box.pack_start(title, False, False, 0)

        desc = Gtk.Label()
        desc.set_markup(
            "LAIA is the AI-ready Linux distribution.\n\n"
            "This wizard will help you set up AI in 3 steps.\n\n"
            "Choose your preferred mode:\n"
            "  ☁️  <b>Online Free</b> — Use free cloud APIs (no hardware needed)\n"
            "  🖥️  <b>Local</b> — Run models on your computer\n"
            "  🌐  <b>LAN Remote</b> — Connect to Ollama on your network\n\n"
            "Let's begin!"
        )
        desc.set_line_wrap(True)
        desc.set_justify(Gtk.Justification.LEFT)
        box.pack_start(desc, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.INTRO)
        self.set_page_title(box, "Welcome")
        self.set_page_complete(box, True)

    def _add_mode_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Choose Your AI Mode</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        # Online Free
        online_box = self._create_mode_radio("Online Free", 
            "Free API keys (Groq, OpenRouter, etc.)\n"
            "30 seconds to get running • No hardware needed\n"
            "300+ tokens/sec with Groq (recommended)", 
            "online")
        box.pack_start(online_box, False, False, 0)

        # Local
        local_box = self._create_mode_radio("Local Inference",
            "Run Ollama models on this computer\n"
            "5-10 minutes to set up • Requires 4GB+ RAM\n"
            "Fully private, works offline",
            "local")
        box.pack_start(local_box, False, False, 0)

        # LAN Remote
        lan_box = self._create_mode_radio("LAN Remote",
            "Connect to Ollama on another machine\n"
            "10 seconds to connect • Shares hardware with LAN\n"
            "Great for home labs and shared servers",
            "lan")
        box.pack_start(lan_box, False, False, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "AI Mode")
        self.set_page_complete(box, False)

    def _create_mode_radio(self, label, description, mode_id):
        frame = Gtk.Frame()
        frame.set_shadow_type(Gtk.ShadowType.NONE)
        
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12, border_width=12)
        
        rb = Gtk.RadioButton(label=label)
        rb.connect("toggled", self._on_mode_selected, mode_id)
        if mode_id == "online":
            rb.set_active(True)
            self.mode = "online"
        box.pack_start(rb, False, False, 0)
        
        desc_label = Gtk.Label(label=description)
        desc_label.set_line_wrap(True)
        desc_label.set_xalign(0)
        desc_label.set_justify(Gtk.Justification.LEFT)
        box.pack_start(desc_label, True, True, 0)
        
        frame.add(box)
        return frame

    def _on_mode_selected(self, rb, mode):
        if rb.get_active():
            self.mode = mode

    def _add_online_provider_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Choose Your Free AI Provider</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        providers = [
            ("groq", "Groq ⭐ (Recommended)", "Fastest: 300-560 tok/sec, no credit card needed"),
            ("openrouter", "OpenRouter", "200+ free models via one API key"),
            ("huggingface", "HuggingFace", "100k+ open models, free token"),
            ("mistral", "Mistral AI", "European AI, strong multilingual"),
            ("google", "Google AI Studio", "Gemini 2.0 Flash, vision-capable"),
        ]

        self.provider_radios = {}
        for provider_id, label, description in providers:
            rb = Gtk.RadioButton(label=f"{label}\n  {description}")
            rb.connect("toggled", self._on_provider_selected, provider_id)
            if provider_id == "groq":
                rb.set_active(True)
                self.provider = "groq"
            rb.set_line_wrap(True)
            self.provider_radios[provider_id] = rb
            box.pack_start(rb, False, False, 0)

        box.pack_start(Gtk.Separator(), False, False, 0)

        api_label = Gtk.Label(label="API Key (will be stored securely):")
        api_label.set_xalign(0)
        box.pack_start(api_label, False, False, 0)

        self.api_key_entry = Gtk.Entry()
        self.api_key_entry.set_visibility(False)
        self.api_key_entry.set_placeholder_text("Paste your API key here...")
        self.api_key_entry.connect("changed", lambda w: setattr(self, 'api_key', w.get_text()))
        box.pack_start(self.api_key_entry, False, False, 0)

        info = Gtk.Label()
        info.set_markup("💡 <small>Click Next to get a free API key</small>")
        info.set_xalign(0)
        box.pack_start(info, False, False, 0)

        self.online_page = box
        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "Online Provider")
        self.set_page_complete(box, False)

    def _on_provider_selected(self, rb, provider):
        if rb.get_active():
            self.provider = provider

    def _add_local_hardware_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Your System</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        # Detect RAM
        try:
            ram_line = open("/proc/meminfo").readline()
            ram_kb = int(ram_line.split()[1])
            self._ram_gb = ram_kb // (1024 * 1024)
        except Exception:
            self._ram_gb = 8

        if self._ram_gb < 8:
            tier_msg = "⚠️ Limited RAM. Only very small models (1-3B) will run smoothly."
        elif self._ram_gb < 16:
            tier_msg = "✅ Good for compact models (3-7B range)."
        elif self._ram_gb < 32:
            tier_msg = "✅ Excellent — most models will run well."
        else:
            tier_msg = "🚀 Powerful — full model library available!"

        info = Gtk.Label()
        info.set_markup(f"<b>RAM:</b> {self._ram_gb} GB\n{tier_msg}")
        info.set_xalign(0)
        box.pack_start(info, False, False, 0)

        models_label = Gtk.Label()
        models_label.set_markup("<b>Models to install:</b>")
        models_label.set_xalign(0)
        box.pack_start(models_label, False, False, 0)

        if self._ram_gb < 8:
            models = [
                ("gemma3:1b", "Gemma 3 (1B) — Ultra-fast", True),
                ("gemma3:4b", "Gemma 3 (4B) — Best compact", True),
            ]
        elif self._ram_gb < 16:
            models = [
                ("gemma3:4b", "Gemma 3 (4B) — Best compact", True),
                ("phi4-mini", "Phi-4 Mini — Great for coding", True),
                ("llama3.2:3b", "Llama 3.2 (3B) — Well-rounded", False),
                ("deepseek-r1:7b", "DeepSeek R1 (7B) — Strong reasoning", False),
            ]
        else:
            models = [
                ("gemma3:4b", "Gemma 3 (4B) — Best compact", True),
                ("phi4-mini", "Phi-4 Mini — Great for coding", True),
                ("deepseek-r1:7b", "DeepSeek R1 (7B) — Strong reasoning", True),
                ("qwen2.5-coder:7b", "Qwen 2.5 Coder (7B) — Best coding", False),
            ]

        self._model_checks = {}
        for model_id, label, default in models:
            cb = Gtk.CheckButton(label=label)
            cb.set_active(default)
            self._model_checks[model_id] = cb
            box.pack_start(cb, False, False, 0)

        self.local_page = box
        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "Local Hardware")
        self.set_page_complete(box, True)

    def _add_lan_remote_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Connect to LAN Ollama</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        desc = Gtk.Label()
        desc.set_markup("Enter the IP address and port of your Ollama server:")
        desc.set_line_wrap(True)
        desc.set_xalign(0)
        box.pack_start(desc, False, False, 0)

        host_label = Gtk.Label(label="Server IP Address:")
        host_label.set_xalign(0)
        box.pack_start(host_label, False, False, 0)

        self.lan_host_entry = Gtk.Entry()
        self.lan_host_entry.set_placeholder_text("e.g., 192.168.1.100")
        self.lan_host_entry.connect("changed", lambda w: setattr(self, 'lan_host', w.get_text()))
        box.pack_start(self.lan_host_entry, False, False, 0)

        port_label = Gtk.Label(label="Port:")
        port_label.set_xalign(0)
        box.pack_start(port_label, False, False, 0)

        self.lan_port_entry = Gtk.Entry()
        self.lan_port_entry.set_text("11434")
        self.lan_port_entry.connect("changed", self._on_lan_port_changed)
        box.pack_start(self.lan_port_entry, False, False, 0)

        self.lan_page = box
        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.CONTENT)
        self.set_page_title(box, "LAN Remote")
        self.set_page_complete(box, False)

    def _on_lan_port_changed(self, entry):
        try:
            self.lan_port = int(entry.get_text())
        except ValueError:
            self.lan_port = 11434

    def _add_summary_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<b>Ready to Configure</b>")
        title.set_xalign(0)
        box.pack_start(title, False, False, 0)

        self.summary_label = Gtk.Label()
        self.summary_label.set_line_wrap(True)
        self.summary_label.set_xalign(0)
        self.summary_label.set_justify(Gtk.Justification.LEFT)
        box.pack_start(self.summary_label, True, True, 0)

        self.summary_page = box
        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.SUMMARY)
        self.set_page_title(box, "Summary")
        self.set_page_complete(box, True)

    def _add_progress_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, border_width=20)

        title = Gtk.Label()
        title.set_markup("<big><b>Configuring LAIA...</b></big>")
        box.pack_start(title, False, False, 0)

        self.progress = Gtk.ProgressBar()
        self.progress.set_show_text(True)
        box.pack_start(self.progress, False, False, 0)

        self.status_label = Gtk.Label(label="Initializing...")
        self.status_label.set_line_wrap(True)
        box.pack_start(self.status_label, True, True, 0)

        self.append_page(box)
        self.set_page_type(box, Gtk.AssistantPageType.PROGRESS)
        self.set_page_title(box, "Configuration")

    def _on_apply(self, assistant):
        self._update_summary()
        self._run_configuration()

    def _update_summary(self):
        if self.mode == "online":
            summary = f"<b>Mode:</b> Online Free\n<b>Provider:</b> {self.provider}\n<b>Ready to save API key</b>"
        elif self.mode == "local":
            selected = [m for m, cb in self._model_checks.items() if cb.get_active()]
            models_str = ", ".join(selected) if selected else "None"
            summary = f"<b>Mode:</b> Local Ollama\n<b>Models:</b> {models_str}"
        else:  # lan
            summary = f"<b>Mode:</b> LAN Remote\n<b>Server:</b> {self.lan_host}:{self.lan_port}"

        self.summary_label.set_markup(summary)

    def _run_configuration(self):
        thread = threading.Thread(target=self._configure_async)
        thread.daemon = True
        thread.start()

    def _configure_async(self):
        try:
            keys_file = os.path.expanduser("~/.laia/api_keys.env")
            os.makedirs(os.path.dirname(keys_file), exist_ok=True)

            if self.mode == "online":
                config = [
                    "LAIA_MODE=online",
                    f"LAIA_PROVIDER={self.provider}",
                    f"LAIA_API_BASE=https://api.groq.com/openai/v1",
                    f"GROQ_API_KEY={self.api_key}",
                ]
            elif self.mode == "local":
                config = ["LAIA_MODE=local"]
            else:
                config = [
                    "LAIA_MODE=lan",
                    f"LAIA_LAN_HOST={self.lan_host}",
                    f"LAIA_LAN_PORT={self.lan_port}",
                ]

            with open(keys_file, 'w') as f:
                f.write("\n".join(config))
            os.chmod(keys_file, 0o600)

            GLib.idle_add(lambda: self._update_progress(100, "Configuration complete!"))
        except Exception as e:
            GLib.idle_add(lambda: self._update_progress(0, f"Error: {e}"))

    def _update_progress(self, value, text):
        self.progress.set_fraction(value / 100.0)
        self.status_label.set_text(text)


def main():
    wizard = SetupWizard()
    wizard.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
