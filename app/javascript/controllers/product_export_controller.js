import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="product-export"
export default class extends Controller {
  test() {
    console.log("=====================hello world! by testing" )
  }
  static targets = ["status", "download"];

  export() {
    console.log("===================== export function")
    fetch('/products/export')
      .then(response => response.json())
      .then(data => {
        const jobId = data.jid;
        this.statusTarget.textContent = "Exporting ...";

        this.timer = setInterval(() => {
          this.checkJobStatus(jobId)
        }, 2000);
      });
  }

  checkJobStatus(jobId) {
    console.log("------------------ function start")
    fetch(`/products/export_status?job_id=${jobId}`)
      .then(response => response.json())
      .then(data => {
        console.log("------------------", data)
        const percentage = data.percentage;
        this.statusTarget.textContent = `Exporting ${percentage}%`;
        if(data.percentage == "100") {
          this.stopCheckJobStatus();
          this.downloadTarget.href = `/products/export_download.xlsx?id=${jobId}`;
          this.downloadTarget.classList.remove("hidden");
        }else if(data.status === "complete") {
          this.stopCheckJobStatus()
        }
      })
  }

  stopCheckJobStatus() {
    if(this.timer) {
      clearInterval(this.timer);
    }
  }

  disconnect() {
    this.stopCheckJobStatus();
  }
}

