import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="product-export"
export default class extends Controller {

  static targets = ["status","jobid", "filenumber", "download"];

  // static targets = ["status", "download"];
  // for current page download
  // export() {
  //   fetch('/products/export')
  //   .then(response => response.json())
  //   .then(data => {
  //     const jobId = data.jid;
  //     const fileNumber = data.file_number;
  //     this.statusTarget.textContent = "Exporting ...";

  //     this.timer = setInterval(() => {
  //       this.checkJobStatus(jobId, fileNumber)
  //     }, 2000);
  //   });
  // }

  // for another page download
  connect() {
    const jobId = this.jobidTarget.textContent;
    const fileNumber = this.filenumberTarget.textContent;
    this.statusTarget.textContent = "Exporting ..."

    this.timer = setInterval(() => {
      this.checkJobStatus(jobId, fileNumber)
    }, 2000);
  }

  checkJobStatus(jobId, fileNumber) {
    fetch(`/products/export_status?job_id=${jobId}`)
      .then(response => response.json())
      .then(data => {
        const percentage = data.percentage;
        this.statusTarget.textContent = `Exporting ${percentage}%`;
        if(data.percentage == "100") {
          this.stopCheckJobStatus();
          this.downloadTarget.href = `/products/export_download.xlsx?id=${jobId}&file_number=${fileNumber}`;
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

