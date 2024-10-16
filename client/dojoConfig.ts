import { createDojoConfig } from "@dojoengine/core";

import manifest from "../dojo/manifests/dev/deployment/manifest.json";

export const dojoConfig = createDojoConfig({
    manifest,
});
