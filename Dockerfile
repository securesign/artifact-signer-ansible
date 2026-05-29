FROM registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9@sha256:70235ed451b9317d9b90e690ffefa6eb2cb6948faed3679b9ec257adcb91023a AS builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY README.md .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

FROM registry.redhat.io/ubi10-minimal@sha256:7dc60d7777e010c50f5e041ff069112b379c3d5eef2823d20871c67cf663f10c
#
LABEL vendor="Red Hat, Inc."
LABEL url="https://www.redhat.com"
LABEL distribution-scope="private"
LABEL version="1.3.5"
LABEL description="Ansible collection to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL)."
LABEL summary="Ansible Collection for Red Hat Trusted Artifact Signer"
LABEL com.redhat.component="rhtas-ansible-collection"
LABEL name="rhtas-ansible-collection"
LABEL io.k8s.description="The image for the rhtas-ansible collection."

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
USER 65532:65532
