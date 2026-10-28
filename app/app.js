async function loadDeploymentInfo() {
  const fields = {
    environment: document.getElementById("environment"),
    version: document.getElementById("version"),
    pod: document.getElementById("pod")
  };

  try {
    const [envResponse, versionResponse, podResponse] = await Promise.all([
      fetch("/config/env.json", { cache: "no-store" }),
      fetch("/version.json", { cache: "no-store" }),
      fetch("/whoami", { cache: "no-store" })
    ]);

    if (!envResponse.ok || !versionResponse.ok || !podResponse.ok) {
      throw new Error("Deployment information unavailable");
    }

    const env = await envResponse.json();
    const version = await versionResponse.json();
    const pod = await podResponse.text();

    fields.environment.textContent = env.environment;
    fields.version.textContent = version.sha;
    fields.pod.textContent = pod.trim();
  } catch (error) {
    console.error(error);
    Object.values(fields).forEach((field) => {
      field.textContent = "Unavailable";
    });
  }
}

document.addEventListener("DOMContentLoaded", loadDeploymentInfo);
