FROM registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9@sha256:7b8269fe0fb5212889837592e7cebfc4cff46f8dc45dcb3442782f0739b1642e AS builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY README.md .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

FROM registry.redhat.io/ubi10-minimal@sha256:29599cb2a44f3275232bc5fc48d26e069e8ba72b710229bed6652633725aa31a
#
LABEL vendor="Red Hat, Inc."
LABEL url="https://www.redhat.com"
LABEL distribution-scope="private"
LABEL version="1.3.4"
LABEL description="Ansible collection to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL)."
LABEL summary="Ansible Collection for Red Hat Trusted Artifact Signer"
LABEL com.redhat.component="rhtas-ansible-collection"
LABEL name="rhtas-ansible-collection"
LABEL io.k8s.description="The image for the rhtas-ansible collection."

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
USER 65532:65532
