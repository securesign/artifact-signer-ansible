FROM registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9@sha256:baf782543d42681d866eaf2262c3ba47b2f55a4e2eeee3ba8eca5e0a35d5ae64 AS builder

WORKDIR /tmp/source

COPY meta/ meta/
COPY roles/ roles/
COPY galaxy.yml .
COPY requirements.yml .
COPY LICENSE .

USER root

RUN ansible-galaxy collection build --force

FROM registry.redhat.io/ubi10-minimal@sha256:f8c05e3c6d15fea32e59635477c0f690e6d4b88a81924e8619f369e57306b701

LABEL vendor="Red Hat, Inc."
LABEL url="https://www.redhat.com"
LABEL distribution-scope="private"
LABEL version="1.2.2"
LABEL description="Ansible collection to automate the deployment of the Red Hat Trusted Artifact Signer (RHTAS) service on Red Hat Enterprise Linux (RHEL)."
LABEL summary="Ansible Collection for Red Hat Trusted Artifact Signer"
LABEL com.redhat.component="rhtas-ansible-collection"
LABEL name="rhtas-ansible-collection"
LABEL io.k8s.description="The image for the rhtas-ansible collection."

COPY LICENSE /licenses/LICENSE
COPY --from=builder /tmp/source/redhat-artifact_signer-*.tar.gz /releases/
USER 65532:65532
