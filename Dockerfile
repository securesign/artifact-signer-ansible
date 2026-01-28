FROM registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9@sha256:2ab70f616905b213f6c2e392ddcd607726e7e8cb9df3da3b2153f30e312ab133 AS builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

FROM registry.redhat.io/ubi10-minimal@sha256:919a5a4c8595deb2f9c21b8a05ad027157f42feb6eed6b64efd1f4f455a5f759

LABEL vendor="Red Hat, Inc."
LABEL url="https://www.redhat.com"
LABEL distribution-scope="private"
LABEL version="1.3.2"
LABEL description="Ansible collection to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL)."
LABEL summary="Ansible Collection for Red Hat Trusted Artifact Signer"
LABEL com.redhat.component="rhtas-ansible-collection"
LABEL name="rhtas-ansible-collection"
LABEL io.k8s.description="The image for the rhtas-ansible collection."

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
USER 65532:65532
