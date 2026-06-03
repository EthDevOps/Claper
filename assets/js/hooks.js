// LiveView hooks for client-side functionality

const Hooks = {
  // Toggles an emoji picker popup and pushes "add-reaction" with the chosen
  // emoji to the LiveView. The container element must include:
  //   [data-emoji-picker-toggle] — the trigger button
  //   [data-emoji-picker-popup]  — the empty popup container
  EmojiPicker: {
    mounted() {
      const toggle = this.el.querySelector("[data-emoji-picker-toggle]");
      const popup = this.el.querySelector("[data-emoji-picker-popup]");
      if (!toggle || !popup) return;

      let picker = null;

      const close = () => {
        popup.classList.add("hidden");
      };

      const open = async () => {
        if (!picker) {
          await import("emoji-picker-element");
          picker = document.createElement("emoji-picker");
          picker.style.setProperty("--background", "white");
          picker.style.setProperty("height", "350px");
          picker.addEventListener("emoji-click", (event) => {
            const emoji = event.detail.unicode;
            this.pushEvent("add-reaction", { emoji });
            close();
          });
          popup.appendChild(picker);
        }
        popup.classList.remove("hidden");
      };

      this._onToggleClick = (event) => {
        event.stopPropagation();
        if (popup.classList.contains("hidden")) {
          open();
        } else {
          close();
        }
      };

      this._onDocClick = (event) => {
        if (!this.el.contains(event.target)) close();
      };

      toggle.addEventListener("click", this._onToggleClick);
      document.addEventListener("click", this._onDocClick);
    },

    destroyed() {
      document.removeEventListener("click", this._onDocClick);
    },
  },

  // Hook for handling CSV downloads from LiveView
  CSVDownloader: {
    mounted() {
      this.handleEvent("download_csv", ({ filename, content }) => {
        // Create a Blob with the CSV content
        const blob = new Blob([content], { type: "text/csv" });
        
        // Create a temporary URL for the Blob
        const url = window.URL.createObjectURL(blob);
        
        // Create a temporary link element
        const link = document.createElement("a");
        link.href = url;
        link.setAttribute("download", filename);
        
        // Append the link to the document body
        document.body.appendChild(link);
        
        // Trigger the download
        link.click();
        
        // Clean up
        window.URL.revokeObjectURL(url);
        document.body.removeChild(link);
      });
    }
  },
  
  // Hook for User Growth Chart
  UserGrowthChart: {
    mounted() {
      // Import Chart.js dynamically
      import("chart.js/auto").then(({ default: Chart }) => {
        const ctx = this.el.getContext("2d");
        const labels = JSON.parse(this.el.dataset.labels);
        const values = JSON.parse(this.el.dataset.values);
        
        this.chart = new Chart(ctx, {
          type: "line",
          data: {
            labels: labels,
            datasets: [{
              label: "New Users",
              data: values,
              borderColor: "#111827",
              backgroundColor: "rgba(17, 24, 39, 0.05)",
              borderWidth: 2,
              tension: 0.4,
              fill: true,
              pointRadius: 0,
              pointHoverRadius: 0,
              pointBackgroundColor: "transparent",
              pointBorderColor: "transparent"
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
              intersect: false,
              mode: 'index'
            },
            plugins: {
              legend: {
                display: false
              },
              tooltip: {
                enabled: true,
                backgroundColor: "rgba(17, 24, 39, 0.9)",
                titleColor: "#fff",
                bodyColor: "#fff",
                borderColor: "#111827",
                borderWidth: 1,
                cornerRadius: 4,
                displayColors: false,
                padding: 8,
                titleFont: {
                  size: 12
                },
                bodyFont: {
                  size: 14,
                  weight: 'bold'
                },
                callbacks: {
                  label: function(context) {
                    return context.parsed.y + ' users';
                  }
                }
              }
            },
            scales: {
              x: {
                display: false
              },
              y: {
                display: false
              }
            }
          }
        });
      });
    },
    
    destroyed() {
      if (this.chart) {
        this.chart.destroy();
      }
    }
  },
  
  // Hook for Event Creation Chart
  EventCreationChart: {
    mounted() {
      // Import Chart.js dynamically
      import("chart.js/auto").then(({ default: Chart }) => {
        const ctx = this.el.getContext("2d");
        const labels = JSON.parse(this.el.dataset.labels);
        const values = JSON.parse(this.el.dataset.values);
        
        this.chart = new Chart(ctx, {
          type: "line",
          data: {
            labels: labels,
            datasets: [{
              label: "New Events",
              data: values,
              borderColor: "#111827",
              backgroundColor: "rgba(17, 24, 39, 0.05)",
              borderWidth: 2,
              tension: 0.4,
              fill: true,
              pointRadius: 0,
              pointHoverRadius: 0,
              pointBackgroundColor: "transparent",
              pointBorderColor: "transparent"
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
              intersect: false,
              mode: 'index'
            },
            plugins: {
              legend: {
                display: false
              },
              tooltip: {
                enabled: true,
                backgroundColor: "rgba(17, 24, 39, 0.9)",
                titleColor: "#fff",
                bodyColor: "#fff",
                borderColor: "#111827",
                borderWidth: 1,
                cornerRadius: 4,
                displayColors: false,
                padding: 8,
                titleFont: {
                  size: 12
                },
                bodyFont: {
                  size: 14,
                  weight: 'bold'
                },
                callbacks: {
                  label: function(context) {
                    return context.parsed.y + ' events';
                  }
                }
              }
            },
            scales: {
              x: {
                display: false
              },
              y: {
                display: false
              }
            }
          }
        });
      });
    },
    
    destroyed() {
      if (this.chart) {
        this.chart.destroy();
      }
    }
  }
};

export default Hooks;
