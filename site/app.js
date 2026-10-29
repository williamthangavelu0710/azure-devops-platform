async function loadDeploymentInfo() {
  const update = (id, value) => {
    document.getElementById(id).textContent = value || "unknown";
  };

  async function load(url, format) {
    try {
      const response = await fetch(url, { cache: "no-store" });
      if (!response.ok) throw new Error(`${url}: ${response.status}`);
      return await response[format]();
    } catch (error) {
      console.warn(error);
      return null;
    }
  }

  const [env, version, pod] = await Promise.all([
    load("/config/env.json", "json"),
    load("/version.json", "json"),
    load("/whoami", "text")
  ]);

  update("environment", env?.environment);
  update("banner", env?.banner);
  update("version", version?.sha);
  update("pod", pod?.trim());
}

document.addEventListener("DOMContentLoaded", loadDeploymentInfo);
