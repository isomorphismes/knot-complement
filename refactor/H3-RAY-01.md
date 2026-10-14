# Checked H³ rays

Origin: https://github.com/isomorphisms/flexible-pipes/issues/131

This extends the existing close C reference. It is a finite numerical kernel for unit-curvature H³, not a renderer, quotient navigator or material solver. Historical sources stay under upstream/ unchanged.

The future hyperboloid uses ⟨P,Q⟩ = PxQx + PyQy + PzQz − PtQt. Points have norm −1 and positive time. A unit ray direction is tangent at its owning point, with norm +1. Public C representations can be forged, so every operation validates the inputs. Point, tangent and transformation roles are documented independently of their four-component representation.

Propagation carries both point and tangent: P(s) = cosh(s)P + sinh(s)V; V(s) = sinh(s)P + cosh(s)V. Distance accumulates across segments. An isometry changes the representative and every frame vector without adding travel. Only orientation- and time-orientation-preserving Lorentz isometries are accepted by the direct-isometry interface. Matrix application uses the historical row-vector convention.

Parallel transport decomposes each frame vector W into its component along V and its perpendicular component, retaining the latter and replacing V by V(s). UHP, Klein and Poincaré conversions apply their derivatives to tangents. Copying coordinate components would give the wrong viewing direction and speed.

Plane events solve tanh(s) = −⟨P,N⟩/⟨V,N⟩. Sphere events solve −⟨P(s),C⟩ = cosh(radius), using stable positive roots in exp(s). The first forward event is compared with the declared distance limit. Starting exactly on a plane, uncertain near-surface/tangent cases, numerical limits and true nonintersections have distinct statuses. An exhausted budget is not a miss. No face epsilon changes the travelled length. Failed/limited operations leave outputs unchanged.

The initial reference bounds coordinate magnitudes by 64 and an individual advance by length 4. This is a deliberately exposed numerical policy, not a boundary of H³. Constraints use absolute residual tolerance 5×10⁻¹⁰ with long-double products; this is a checked floating reference, not an interval-certified proof. Recentring or a better conditioned representation is needed before a state leaves the admitted range. Tangencies and near-surface decisions may return UNRESOLVED.

The tests use exact log-2 fractions, full frame transport, coordinate derivatives, inverse travel, composition, sphere entry/exit, plane events, invalid data and no output mutation on refusal. Compiling mutants that freeze the direction or reset travelled length must fail. AI-CI independently consumes 34 scalar fields, recomputes upper-half-space distance and speed, rejects corrupt outputs, and observes the rejecting processes.

The retained float recenter reference now rejects spacelike, opposite-sheet, zero and nonfinite points; invalid transforms and a nonidentity first neighbor cannot become successful nearest-copy results. Its printed historical matrices retain their existing precision and tolerance. Neighbor-set adequacy remains an input obligation; these tests do not establish an m004 atlas.

All new consumer compilation is through pinned ICK c61e448251744a2f40ad743ebef1a027bdcd2f9d, using the qualified AI-CI host action. The existing Python Flexible Pipes runner is unchanged migration debt. Its command stages record exact argv, heads, stdout/stderr and hashes. A green host kernel does not supply Kitchen/Ike release qualification, GPU execution, Android behavior or a handmade surface. Those evidence columns remain separate.

